require 'rails_helper'

=begin
  q = DwcOccurrence.where(project_id: 1)
  d = Export::Dwca::Data.new(
    core_scope: q,
    predicate_extensions: {
      collecting_event_predicate_id: [
                           435, 436, 437, 438, 439, 440, 441, 442, 444, 445, 446, 447, 448, 449, 450, 451, 452, 453, 454, 455, 458, 459, 460, 461, 462, 463, 464, 465, 500, 501, 502, 503, 707, 708, 709, 710, 711, 712, 713, 714, 715, 716, 717, 718, 719, 720, 721, 722, 725, 726, 727, 728, 729, 730, 731, 732, 733, 734, 735, 736, 908, 909, 910
      ],
      collection_object_predicate_id: [
                           435, 436, 437, 442, 445, 447, 448, 451, 454, 456, 457, 459, 460, 463, 464, 465, 466, 475, 476, 477, 478, 479, 480, 481, 482, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 495, 496, 497, 498, 500, 501, 502, 503, 975
      ],
      taxonworks_extensions: [
        :collection_object_id, :collecting_event_id, :elevation_precision, :otu_name
      ]
    }
  )

  # sandbox ce:         6, 7, 8, 13, 18, 19, 22, 25, 30, 31, 34, 35, 36, 71, 72, 73, 74
  # sandbox co:         6, 7, 8, 13, 16, 18, 19, 25, 27, 28, 30, 31, 34, 35, 36, 37, 46, 47, 48, 49, 50, 51, 52, 53, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 66, 67, 68, 69, 71, 72, 73, 74, 7905

=end

describe Export::Dwca::Data, type: :model, group: :darwin_core do
  let(:scope) { ::DwcOccurrence.all }

  # Headers added when we spec a Specimen with a ce that is a valid_collecting_events
  let(:valid_collecting_event_headers) { %w{georeferenceProtocol verbatimCoordinates verbatimElevation verbatimLatitude verbatimLocality verbatimLongitude} }

  specify 'optimizations using ::CollectionObject::EXTENSION_COMPUTED_FIELDS are noted' do
    # If this spec breaks then see def taxonworks_extension_data
    # for required changes before it can be updated
    expect(::CollectionObject::EXTENSION_COMPUTED_FIELDS).to eq({otu_name: :otu_name})
  end

  specify 'initializing without a scope raises' do
    expect {Export::Dwca::Data.new()}.to raise_error ArgumentError
  end

  specify 'initializing with a DwcOccurrence scope succeeds' do
    a = Export::Dwca::Data.new(core_scope: scope).core_scope.to_sql
    expect(a.include?('ORDER BY dwc_occurrences.id')).to be_truthy
  end

  context 'when initialized with a scope' do
    let(:data) { Export::Dwca::Data.new(core_scope: scope) }

    specify 'initializing with a DwcOccurrence scope succeeds' do
      expect(Export::Dwca::Data.new(core_scope: scope)).to be_truthy
    end

    specify '#csv returns csv String' do
      expect(data.csv).to be_kind_of( String )
    end

    context 'with some occurrence records created' do
      before do
        5.times do
          f = FactoryBot.create(:valid_specimen, collecting_event: FactoryBot.create(:valid_collecting_event))
          f.get_dwc_occurrence
        end
      end

      after { data.cleanup }

      let(:csv) { CSV.parse(data.csv, headers: true, col_sep: "\t") }

      # id, and non-standard DwC columns are handled elsewhere
      let(:headers) { [ 'basisOfRecord', 'individualCount', 'occurrenceID', 'occurrenceStatus' ] }

      specify '#collection_object_ids' do
        d = Export::Dwca::Data.new(core_scope: scope).collection_object_ids
        expect(d).to eq(CollectionObject.joins(:dwc_occurrence).order('dwc_occurrences.id').pluck(:dwc_occurrence_object_id))
      end

      specify '#collection_objects 1' do
        d = Export::Dwca::Data.new(core_scope: scope).collection_objects
        expect(d.all).to contain_exactly(*CollectionObject.joins(:dwc_occurrence).order('dwc_occurrences.id').to_a)
      end

      specify '#collection_objects 1' do
        s1 = Specimen.order(:id).first
        s2 = Specimen.order(:id).last
        d = Export::Dwca::Data.new(core_scope: scope.where(dwc_occurrence_object_id: [s1.id, s2.id])).collection_objects
        expect(d.all).to contain_exactly(s1, s2)
      end

      specify '#collecting_events 1' do
        d = Export::Dwca::Data.new(core_scope: scope).collecting_events
        expect(d.to_a).to contain_exactly(*CollectingEvent.all.to_a)
      end

      specify '#collecting_events 2' do
        d = Export::Dwca::Data.new(core_scope: scope).collecting_events
        expect(d.to_a).to contain_exactly(*CollectingEvent.all.to_a)
      end

      context 'various scopes' do
        specify 'with .where clauses' do
          s = scope.where('id > 1')
          d = Export::Dwca::Data.new(core_scope: s)
          expect(d.meta_fields).to contain_exactly(*( headers + valid_collecting_event_headers))
        end

        specify 'with .order clauses' do
          s = scope.order(:basisOfRecord)
          d = Export::Dwca::Data.new(core_scope: s)
          expect(d.meta_fields).to contain_exactly(*(headers + valid_collecting_event_headers) )
        end

        specify 'with .join clauses' do
          s = scope.collection_objects_join
          d = Export::Dwca::Data.new(core_scope: s)
          expect(d.meta_fields).to contain_exactly(*(headers + valid_collecting_event_headers))
        end
      end

      context 'extension_scopes: [:biological_associations]' do
        let(:biological_relationship) { FactoryBot.create(:valid_biological_relationship) }
        let!(:ba1) { BiologicalAssociation.create!(biological_relationship:, biological_association_subject: CollectionObject.first, biological_association_object: CollectionObject.last) }
        let(:biological_association_scope) { BiologicalAssociation.all }

        specify '#biological_associations_resource_relationship is a tempfile' do
          s = scope.where('id > 1')
          d = Export::Dwca::Data.new(core_scope: s, extension_scopes: { biological_associations:  biological_association_scope  })
          expect(d.biological_associations_resource_relationship).to be_kind_of(Tempfile)
        end

        specify '#biological_associations_resource_relationship returns lines for specimens' do
          s = scope.where('id > 1')
          d = Export::Dwca::Data.new(core_scope: s, extension_scopes: { biological_associations:  biological_association_scope  })
          expect(d.biological_associations_resource_relationship.count).to eq(2)
        end
      end

      context ':predicate_extensions with orphaned collection objects' do
        let(:p1) { FactoryBot.create(:valid_predicate)}
        let(:p2) { FactoryBot.create(:valid_predicate)}
        let(:p3) { FactoryBot.create(:valid_predicate)}
        let(:predicate_ids) { [p3.id, p1.id, p2.id] } # purposefully out of order

        after { data.cleanup }

        specify 'stale DwcOccurrence index does not raise' do
          s = Specimen.all
          f = Specimen.first
          m = Specimen.third
          l = Specimen.last

          d1 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: f, predicate: p1 )
          d2 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: l, predicate: p3 )
          d3 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: m, predicate: p2 )

          c = FactoryBot.create(:valid_collecting_event)
          d4 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p1 )

          m.update!(collecting_event: c)

          a = Export::Dwca::Data.new(core_scope: scope, predicate_extensions: {collection_object_predicate_id: predicate_ids, collecting_event_predicate_id: predicate_ids } )

          # TODO: Are these breaking specs?!
          # Orphan DwcOccurrence
          f.delete
          l.delete
          m.delete

          expect{a.predicate_data}.not_to raise_error

          a.cleanup
        end

        specify 'orders values into the right rows' do
          s = Specimen.all
          f = Specimen.first
          m = Specimen.third
          l = Specimen.last

          d1 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: f, predicate: p1 )
          d2 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: l, predicate: p3 )
          d3 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: m, predicate: p2 )

          c = FactoryBot.create(:valid_collecting_event)
          d4 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p1 )

          m.update!(collecting_event: c)

          a = Export::Dwca::Data.new(core_scope: scope, predicate_extensions: {collection_object_predicate_id: predicate_ids, collecting_event_predicate_id: predicate_ids } )

          f = a.predicate_data.read

          z = CSV.parse(f, headers: true)

          expect(z.to_a[1].first).to include(d1.value)
          expect(z.to_a[3].first).to include(d4.value) # the ce value
          expect(z.to_a[3].first).to include(d3.value)
          expect(z.to_a[5].first).to include(d2.value)

          a.cleanup
        end

        specify 'destruction of DataAttribute post instantiation is caught' do
          s = Specimen.all
          f = Specimen.first
          m = Specimen.third
          l = Specimen.last

          d1 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: f, predicate: p1 )
          d2 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: l, predicate: p3 )
          d3 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: m, predicate: p2 )

          c = FactoryBot.create(:valid_collecting_event)
          d4 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p1 )

          m.update!(collecting_event: c)

          a = Export::Dwca::Data.new(core_scope: scope, predicate_extensions: {collection_object_predicate_id: predicate_ids, collecting_event_predicate_id: predicate_ids } )

          d1.destroy!
          d2.destroy!

          expect{a.predicate_data}.not_to raise_error
          a.cleanup
        end

        specify 'orders values into the right rows 2' do
          s = Specimen.all
          f = Specimen.first
          m = Specimen.third
          l = Specimen.last

          d1 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: f, predicate: p1 )
          d2 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: l, predicate: p3 )
          d3 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: m, predicate: p2 )

          c = FactoryBot.create(:valid_collecting_event)
          d4 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p1 )

          m.update!(collecting_event: c)

          a = Export::Dwca::Data.new(core_scope: scope, predicate_extensions: {collection_object_predicate_id: predicate_ids, collecting_event_predicate_id: predicate_ids } )

          f = a.predicate_data.read

          z = CSV.parse(f, headers: true)

          expect(z.to_a[1].first).to include(d1.value)
          expect(z.to_a[3].first).to include(d4.value) # the ce value
          expect(z.to_a[3].first).to include(d3.value)

          expect(z.to_a[5].first).to include(d2.value)

          a.cleanup
        end

        specify '#collection_object_attributes_query' do
          # All three share CE
          f = Specimen.first
          m = Specimen.third
          l = Specimen.last

          c = FactoryBot.create(:valid_collecting_event)
          f.update!(collecting_event: c)
          m.update!(collecting_event: c)
          l.update!(collecting_event: c)

          # The collecting event has a data attributes
          d1 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p1 )

          # The scope is only two specimens
          q = DwcOccurrence.where(dwc_occurrence_object: Specimen.where(id: [f.id, m.id]))

          a = Export::Dwca::Data.new(core_scope: q, predicate_extensions: {collecting_event_predicate_id: [p1.id] } )

          expect(a.collecting_event_attributes_query.to_a).to contain_exactly(d1)

          a.cleanup
        end

        specify '#collecting_event_attributes, does not inject collection_object_ids via collecting events for collection_objects not referenced in the origin scope' do
          # All three share CE
          f = Specimen.first
          m = Specimen.third
          l = Specimen.last

          c = FactoryBot.create(:valid_collecting_event)

          f.update!(collecting_event: c)
          m.update!(collecting_event: c)
          l.update!(collecting_event: c)

          # The collecting event has a data attributes
          d1 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p1 )

          # The scope is only two specimens
          q = DwcOccurrence.where(dwc_occurrence_object: Specimen.where(id: [f.id, m.id]))

          a = Export::Dwca::Data.new(core_scope: q, predicate_extensions: {collecting_event_predicate_id: [p1.id] } )

          expect(a.collecting_event_attributes).to contain_exactly(
            [f.id, "TW:DataAttribute:CollectingEvent:#{p1.name}", d1.value ],
            [m.id, "TW:DataAttribute:CollectingEvent:#{p1.name}", d1.value ]
          )

          a.cleanup
        end

        specify '#collection_object_attributes' do
          s = Specimen.all
          f = Specimen.first
          m = Specimen.third
          l = Specimen.last

          d1 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: f, predicate: p1 )
          d2 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: l, predicate: p3 )
          d3 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: m, predicate: p2 )

          a = Export::Dwca::Data.new(core_scope: scope, predicate_extensions: {collection_object_predicate_id: predicate_ids } )

          expect(a.collection_object_attributes).to include([f.id, "TW:DataAttribute:CollectionObject:#{p1.name}", d1.value])
          expect(a.collection_object_attributes).to include([l.id, "TW:DataAttribute:CollectionObject:#{p3.name}", d2.value])

          a.cleanup
        end

        specify '#collecting_event_attributes' do
          f = Specimen.first

          c = FactoryBot.create(:valid_collecting_event)
          d4 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p1 )

          f.update!(collecting_event: c)

          d1 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p1 )
          d2 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p3 )

          a = Export::Dwca::Data.new(core_scope: scope, predicate_extensions: {collecting_event_predicate_id: predicate_ids } )

          expect(a.collecting_event_attributes).to include([f.id, "TW:DataAttribute:CollectingEvent:#{p1.name}", d1.value])
          expect(a.collecting_event_attributes).to include([f.id, "TW:DataAttribute:CollectingEvent:#{p3.name}", d2.value])

          a.cleanup
        end

        specify '#used_predicates 1' do
          f = Specimen.first

          c = FactoryBot.create(:valid_collecting_event)
          d4 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p1 )

          f.update!(collecting_event: c)

          d1 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p1 )
          d2 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p3 )

          a = Export::Dwca::Data.new(core_scope: scope, predicate_extensions: {collecting_event_predicate_id: predicate_ids } )

          expect(a.used_predicates).to contain_exactly("TW:DataAttribute:CollectingEvent:#{p1.name}", "TW:DataAttribute:CollectingEvent:#{p3.name}")

          a.cleanup
        end

        specify '#used_predicates 2' do
          f = Specimen.first

          c = FactoryBot.create(:valid_collecting_event)
          d4 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p1 )

          f.update!(collecting_event: c)

          d1 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p1 )
          d2 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p3 )
          d3 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: f, predicate: p2 ) # Not requested

          a = Export::Dwca::Data.new(core_scope: scope, predicate_extensions: {collecting_event_predicate_id: predicate_ids } )

          expect(a.used_predicates).to contain_exactly(
            "TW:DataAttribute:CollectingEvent:#{p1.name}",
            "TW:DataAttribute:CollectingEvent:#{p3.name}"
          )

          a.cleanup
        end
      end

      specify '#dwc_id_order' do
        # zero! Like  {1=>0, 2=>1, 3=>2, 4=>3, 5=>4}
        d = Export::Dwca::Data.new(core_scope: scope, taxonworks_extensions: [:otu_name])
        o = Specimen.order(:id).pluck(:id).map.with_index.to_h
        expect(d.dwc_id_order).to eq(o)
      end

      context 'taxonworks_extensions for internal attributes' do
        context '#taxonworks_extension_data' do
          let(:o1) { Otu.create(name: 'aus') }
          let(:o2) { Otu.create(name: 'bus') }
          let(:o3) { Otu.create(name: 'cus') }

          specify 'exports in the correct order' do
            s1 = Specimen.order(:id).first
            s2 = Specimen.order(:id).third
            s3 = Specimen.order(:id).last

            d1 = TaxonDetermination.create( otu: o1, taxon_determination_object: s1)
            d2 = TaxonDetermination.create( otu: o2, taxon_determination_object: s3)
            d3 = TaxonDetermination.create( otu: o3, taxon_determination_object: s2)

            d = Export::Dwca::Data.new(core_scope: scope, taxonworks_extensions: [:otu_name])

            e = d.taxonworks_extension_data.read

            z = CSV.parse(e, headers: true)

            expect(z.to_a[1].first).to eq(d1.otu.name)
            expect(z.to_a[2].first).to eq(nil)
            expect(z.to_a[3].first).to eq(d3.otu.name)
            expect(z.to_a[4].first).to eq(nil)
            expect(z.to_a[5].first).to eq(d2.otu.name)

            d.cleanup
          end

          specify 'exports in the correct order (otu attributes)' do
            s1 = Specimen.order(:id).first
            s2 = Specimen.order(:id).third
            s3 = Specimen.order(:id).last

            d1 = TaxonDetermination.create( otu: o1, taxon_determination_object: s1)
            d2 = TaxonDetermination.create( otu: o2, taxon_determination_object: s3)
            d3 = TaxonDetermination.create( otu: o3, taxon_determination_object: s2)

            d = Export::Dwca::Data.new(core_scope: scope, taxonworks_extensions: [:otu_name])

            e = d.taxonworks_extension_data.read

            z = CSV.parse(e, headers: true)

            expect(z.to_a[1].first).to eq(d1.otu.name)
            expect(z.to_a[2].first).to eq(nil)
            expect(z.to_a[3].first).to eq(d3.otu.name)
            expect(z.to_a[4].first).to eq(nil)
            expect(z.to_a[5].first).to eq(d2.otu.name)

            d.cleanup
          end

          specify 'exports in the correct order (ce attributes)' do
            s1 = Specimen.order(:id).first
            s2 = Specimen.order(:id).third
            s3 = Specimen.order(:id).last

            c1 = FactoryBot.create(:valid_collecting_event, elevation_precision: 1.0 )
            c2 = FactoryBot.create(:valid_collecting_event, elevation_precision: 2.0 )
            c3 = FactoryBot.create(:valid_collecting_event, elevation_precision: 3.0 )

            s1.update!(collecting_event: c1)
            s3.update!(collecting_event: c2)
            s2.update!(collecting_event: c3)

            d = Export::Dwca::Data.new(core_scope: scope, taxonworks_extensions: [:elevation_precision])

            e = d.taxonworks_extension_data.read

            z = CSV.parse(e, headers: true)

            expect(z.to_a[1].first).to eq(c1.elevation_precision)
            expect(z.to_a[2].first).to eq(nil)
            expect(z.to_a[3].first).to eq(c3.elevation_precision)
            expect(z.to_a[4].first).to eq(nil)
            expect(z.to_a[5].first).to eq(c2.elevation_precision)

            d.cleanup
          end

          specify 'exports in the correct order (ce & co attributes)' do
            s1 = Specimen.order(:id).first
            s2 = Specimen.order(:id).third
            s3 = Specimen.order(:id).last

            c1 = FactoryBot.create(:valid_collecting_event, elevation_precision: 1.0 )
            c2 = FactoryBot.create(:valid_collecting_event, elevation_precision: 2.0 )
            c3 = FactoryBot.create(:valid_collecting_event, elevation_precision: 3.0 )

            d1 = TaxonDetermination.create( otu: o1, taxon_determination_object: s1)

            s1.update!(collecting_event: c1)
            s3.update!(collecting_event: c2)
            s2.update!(collecting_event: c3)

            d = Export::Dwca::Data.new(core_scope: scope, taxonworks_extensions: [:otu_name, :elevation_precision])

            e = d.taxonworks_extension_data.read

            z = CSV.parse(e, headers: true)

            expect(z.to_a).to eq(
              [
                [ "TW:Internal:otu_name\tTW:Internal:elevation_precision" ],
                [ "aus\t1.0" ],
                [ "\t" ],
                [ "\t3.0" ],
                [ "\t" ],
                [ "\t2.0" ]
              ]
            )

            d.cleanup
          end

          specify 'collection objects without dwc_occurrences, with (ce & co attributes), with (potentially) interfering AssertedDistribution' do
            s1 = Specimen.order(:id).first
            s2 = Specimen.order(:id).third
            s3 = Specimen.order(:id).last

            c1 = FactoryBot.create(:valid_collecting_event, elevation_precision: 1.0 )
            c2 = FactoryBot.create(:valid_collecting_event, elevation_precision: 2.0 )

            d1 = TaxonDetermination.create( otu: o1, taxon_determination_object: s3)

            s1.update!(collecting_event: c1)
            s2.update!(collecting_event: c1) # not this!
            s3.update!(collecting_event: c2)

            d = Export::Dwca::Data.new(core_scope: scope.where(dwc_occurrence_object_id: [s1.id, s3.id, s2.id]), taxonworks_extensions: ::CollectionObject::DwcExtensions::TaxonworksExtensions::EXTENSION_FIELDS)

            s2.dwc_occurrence.delete # !!

            qq = FactoryBot.create(:valid_asserted_distribution, otu: o1)

            e = d.taxonworks_extension_data.read

            z = CSV.parse(e, headers: true)

            expect(z.to_a).to eq(
              [["TW:Internal:otu_name\tTW:Internal:collecting_event_id\tTW:Internal:elevation_precision\tTW:Internal:collection_object_id"], ["\t151\t1.0\t151"], ["aus\t155\t2.0\t155"]]
            )
          end

          specify '#extension_computed_fields_data' do
            s1 = Specimen.order(:id).first
            s2 = Specimen.order(:id).third
            s3 = Specimen.order(:id).last

            c1 = FactoryBot.create(:valid_collecting_event, elevation_precision: 1.0 )
            c2 = FactoryBot.create(:valid_collecting_event, elevation_precision: 2.0 )

            d1 = TaxonDetermination.create( otu: o1, taxon_determination_object: s3)

            s1.update!(collecting_event: c1)
            s2.update!(collecting_event: c1) # not this!
            s3.update!(collecting_event: c2)

            d = Export::Dwca::Data.new(core_scope: scope.where(dwc_occurrence_object_id: [s1.id, s3.id, s2.id]), taxonworks_extensions: ::CollectionObject::DwcExtensions::TaxonworksExtensions::EXTENSION_FIELDS)

            # Mess with things
            s2.dwc_occurrence.delete
            qq = FactoryBot.create(:valid_asserted_distribution, otu: o1)

            expect(d.extension_computed_fields_data({otu_name: 'TW:Internal:otu_name' })).to eq(
              [[s1.id, 'TW:Internal:otu_name', nil], [s3.id, 'TW:Internal:otu_name', "aus"]]
            )

          end

        end

        context 'exporting otu_name' do
          let(:d) {Export::Dwca::Data.new(core_scope: scope, taxonworks_extensions: [:otu_name])}
          let!(:o) {FactoryBot.create(:valid_otu)}
          let!(:det) {FactoryBot.create(
            :valid_taxon_determination,
            otu: o,
            taxon_determination_object: DwcOccurrence.last.dwc_occurrence_object)}

          specify 'the COs should have OTUs' do
            expect(DwcOccurrence.last.dwc_occurrence_object.current_otu).to_not be_nil
          end

          specify '#taxon_works_extension_data is a tempfile' do
            expect(d.taxonworks_extension_data).to be_kind_of(Tempfile)
          end

          specify '#taxonworks_extension_data returns lines for specimens' do
            expect(d.taxonworks_extension_data.count).to eq(6)
          end

          specify 'should have the correct headers' do
            headers = %w[basisOfRecord individualCount occurrenceID occurrenceStatus TW:Internal:otu_name]
            expect(d.meta_fields).to contain_exactly(*(headers + valid_collecting_event_headers) )
          end

          specify 'should have the otu name in the correct extension file row' do
            expect(File.readlines(d.taxonworks_extension_data).last&.strip).to eq(o.name)
          end

          specify 'should have the otu name in the combined file' do
            expect(File.readlines(d.all_data).last).to include(o.name)
          end
        end

        context 'exporting header with different api column name' do
          let(:d) { Export::Dwca::Data.new(core_scope: scope, taxonworks_extensions: [:collection_object_id]) }

          specify 'should have the correct headers' do
            headers = %w[basisOfRecord individualCount occurrenceID occurrenceStatus TW:Internal:collection_object_id]
            expect(d.meta_fields).to contain_exactly(*( headers + valid_collecting_event_headers) )
          end

          specify 'should have the collection_object_id in the correct extension file row' do
            expect(File.readlines(d.taxonworks_extension_data).last&.strip).to eq(CollectionObject.last.id.to_s)
          end

          specify 'should have the collection_object_id in the combined file' do
            expect(File.readlines(d.all_data).last).to include(CollectionObject.last.id.to_s)
          end
        end

        context 'exporting elevation_precision' do
          let(:d) { Export::Dwca::Data.new(core_scope: scope, taxonworks_extensions: [:elevation_precision]) }
          let(:ce) { FactoryBot.create(:valid_collecting_event, minimum_elevation: 100, elevation_precision: '10 m') }

          before do
            co = CollectionObject.last
            co.collecting_event_id = ce.id
            co.save!
          end

          specify 'should have the elevation precision in the correct extension file row' do
            expect(File.readlines(d.taxonworks_extension_data).last&.strip).to eq(ce.elevation_precision)
          end

          specify 'should have the elevation precision in the combined file' do
            expect(File.readlines(d.all_data).last).to include(ce.elevation_precision)
          end
        end

        context 'when no extensions are selected' do
          let(:empty_extension) { Export::Dwca::Data.new(core_scope: scope, taxonworks_extensions: []) }

          specify '#taxonworks_extension_data should be a tempfile' do
            expect(empty_extension.taxonworks_extension_data).to be_kind_of(Tempfile)
          end

          specify '#taxon_works_extension_data should generate a blank file' do
            expect(empty_extension.taxonworks_extension_data.count).to eq(0)
          end

          specify 'the datafile should have only the standard headers' do
            expect(empty_extension.meta_fields).to contain_exactly(*(headers + valid_collecting_event_headers))
          end
        end
      end

      specify '#csv returns lines for specimens' do
        expect(csv.count).to eq(5)
      end

      specify 'TW housekeeping columns are not present' do
        expect(csv.headers).not_to include('project_id', 'created_by_id', 'updated_by_id')
      end

      specify 'generated headers are restricted to data' do
        expect(csv.headers).to contain_exactly(*(['id'] + headers + valid_collecting_event_headers ))
      end

      specify '#meta_fields can be returned, and exclude id' do
        expect(data.meta_fields).to contain_exactly(*(headers + valid_collecting_event_headers) )
      end

      context 'files' do
        specify '#data is a tempfile' do
          expect(data.data).to be_kind_of(Tempfile)
        end

        specify '#eml is a tempfile' do
          expect(data.eml).to be_kind_of(Tempfile)
        end

        specify '#meta is a tempfile' do
          expect(data.meta).to be_kind_of(Tempfile)
        end

        specify '#zipfile is a Tempfile' do
          expect(data.zipfile).to be_kind_of(Tempfile)
        end

        specify '#predicate_data is a Tempfile' do
          expect(data.predicate_data).to be_kind_of(Tempfile)
        end

        specify '#package_download packages' do
          d = FactoryBot.build(:valid_download)
          expect(data.package_download(d)).to be_truthy
        end

        specify '#package_download 2' do
          d = FactoryBot.build(:valid_download)
          data.package_download(d)
          expect(File.exist?(d.file_path)).to be_truthy
        end
      end

      # TODO: actually check tempfile directory
      specify '#cleanup' do
        expect(data.cleanup).to be_truthy
      end
    end

  end
end
