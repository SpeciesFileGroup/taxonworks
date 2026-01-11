require 'rails_helper'

describe Export::Dwca::Occurrence::Data, type: :model, group: :darwin_core do
  let(:scope) { ::DwcOccurrence.all }

  # Headers added when we spec a Specimen with a ce that is a valid_collecting_events
  let(:valid_collecting_event_headers) { %w{georeferenceProtocol verbatimCoordinates verbatimElevation verbatimLatitude verbatimLocality verbatimLongitude} }

  specify 'optimizations using ::CollectionObject::EXTENSION_COMPUTED_FIELDS are noted' do
    # If this spec breaks then see def taxonworks_extension_data
    # for required changes before it can be updated
    expect(::CollectionObject::EXTENSION_COMPUTED_FIELDS).to eq({otu_name: :otu_name})
  end

  specify 'initializing without a scope raises' do
    expect {Export::Dwca::Occurrence::Data.new()}.to raise_error ArgumentError
  end

  context 'when initialized with a scope' do
    let(:data) { Export::Dwca::Occurrence::Data.new(core_scope: scope) }

    specify 'initializing with a DwcOccurrence scope orders by id' do
      a = Export::Dwca::Occurrence::Data.new(core_scope: scope).core_scope.to_sql
      expect(a.include?('ORDER BY dwc_occurrences.id')).to be_truthy
    end

    specify '#data returns tempfile with CSV data' do
      tempfile = data.data
      expect(tempfile).to be_kind_of(Tempfile)
      expect(tempfile.size).to be > 0
    end

    context 'with some occurrence records created' do
      before do
        5.times do
          f = FactoryBot.create(:valid_specimen, collecting_event: FactoryBot.create(:valid_collecting_event))
          f.get_dwc_occurrence
        end
      end

      let(:csv) {
        tempfile = data.data
        tempfile.rewind
        CSV.parse(tempfile.read, headers: true, col_sep: "\t")
      }

      let(:headers) { [ 'basisOfRecord', 'individualCount', 'occurrenceID', 'occurrenceStatus' ] }

      specify '#meta_fields returns expected header fields' do
        s = scope.where('id > 1')
        d = Export::Dwca::Occurrence::Data.new(core_scope: s)
        expect(d.meta_fields).to contain_exactly(*( headers + valid_collecting_event_headers))
      end

      context 'extension_scopes: [:biological_associations]' do
        let(:biological_relationship) { FactoryBot.create(:valid_biological_relationship) }
        let!(:ba1) { BiologicalAssociation.create!(biological_relationship:, biological_association_subject: CollectionObject.first, biological_association_object: CollectionObject.last) }
        let(:biological_association_scope) {
          { core_params: {},
            collection_objects_query: BiologicalAssociation.all
          }
        }

        specify '#biological_associations_resource_relationship_tmp is a tempfile' do
          s = scope.where('id > 1')
          d = Export::Dwca::Occurrence::Data.new(core_scope: s, extension_scopes: { biological_associations:  biological_association_scope  })
          expect(d.biological_associations_resource_relationship_tmp).to be_kind_of(Tempfile)
        end

        specify '#biological_associations_resource_relationship_tmp returns lines for specimens' do
          s = scope.where('id > 1')
          d = Export::Dwca::Occurrence::Data.new(core_scope: s, extension_scopes: { biological_associations:  biological_association_scope  })
          # 1 header line, two ba lines, one for each direction of the
          # relationship.
          expect(d.biological_associations_resource_relationship_tmp.count).to eq(3)
        end
      end

      context 'extension_scopes: [:media]' do
        let!(:fo) { FactoryBot.create(:valid_field_occurrence) }
        let(:media_scope) { { collection_objects: CollectionObject.all.to_sql, field_occurrences: FieldOccurrence.all.to_sql } }

        before(:all) {
          Project.first.update!(set_new_api_access_token: true)
        }

        specify '#media_tmp is a tempfile' do
          s = scope.where('id > 1')
          d = Export::Dwca::Occurrence::Data.new(core_scope: s, extension_scopes: { media: media_scope })
          expect(d.media_tmp).to be_kind_of(Tempfile)
        end

        specify '#media_tmp header row starts with "coreid"' do
          s = scope.where('id > 1')
          d = Export::Dwca::Occurrence::Data.new(core_scope: s, extension_scopes: { media: media_scope })
          expect(d.media_tmp.first).to start_with('coreid')
        end

        specify '#media_tmp returns lines for specimen images' do
          FactoryBot.create(:valid_depiction, depiction_object: CollectionObject.last)
          s = scope.where('id > 1')
          d = Export::Dwca::Occurrence::Data.new(core_scope: s, extension_scopes: { media: media_scope })
          expect(d.media_tmp.count).to eq(2)
        end

        specify '#media_tmp returns lines for specimen sounds' do
          FactoryBot.create(:valid_conveyance, conveyance_object: CollectionObject.last)
          s = scope.where('id > 1')
          d = Export::Dwca::Occurrence::Data.new(core_scope: s, extension_scopes: { media: media_scope })
          expect(d.media_tmp.count).to eq(2)
        end

        specify '#media_tmp returns lines for specimen observation images' do
          co = CollectionObject.last
          o = FactoryBot.create(:valid_observation, observation_object: co)
          FactoryBot.create(:valid_depiction, depiction_object: o)
          s = scope.where('id > 1')
          d = Export::Dwca::Occurrence::Data.new(core_scope: s, extension_scopes: { media: media_scope })
          expect(d.media_tmp.count).to eq(2)
        end

        # TODO: bring this back once conveyances are back on Observations.
        xspecify '#media_tmp returns lines for specimen observation sounds' do
          co = CollectionObject.last
          o = FactoryBot.create(:valid_observation, observation_object: co)
          FactoryBot.create(:valid_conveyance, conveyance_object: o)
          s = scope.where('id > 1')
          d = Export::Dwca::Occurrence::Data.new(core_scope: s, extension_scopes: { media: media_scope })
          expect(d.media_tmp.count).to eq(2)
        end

        specify '#media_tmp returns lines for field occurrence images' do
          FactoryBot.create(:valid_depiction, depiction_object: FieldOccurrence.last)
          s = scope.where('id > 1')
          d = Export::Dwca::Occurrence::Data.new(core_scope: s, extension_scopes: { media: media_scope })
          expect(d.media_tmp.count).to eq(2)
        end

        specify '#media_tmp returns lines for field occurrence sounds' do
          FactoryBot.create(:valid_conveyance, conveyance_object: FieldOccurrence.last)
          s = scope.where('id > 1')
          d = Export::Dwca::Occurrence::Data.new(core_scope: s, extension_scopes: { media: media_scope })
          expect(d.media_tmp.count).to eq(2)
        end

        specify '#media_tmp returns lines for field occurrence observation images' do
          fo = FieldOccurrence.last
          o = FactoryBot.create(:valid_observation, observation_object: fo)
          FactoryBot.create(:valid_depiction, depiction_object: o)
          s = scope.where('id > 1')
          d = Export::Dwca::Occurrence::Data.new(core_scope: s, extension_scopes: { media: media_scope })

          expect(d.media_tmp.count).to eq(2)
        end

        # TODO: bring this back once conveyances are back on Observations.
        xspecify '#media_tmp returns lines for field occurrence observation sounds' do
          fo = FieldOccurrence.last
          o = FactoryBot.create(:valid_observation, observation_object: fo)
          FactoryBot.create(:valid_conveyance, conveyance_object: o)
          s = scope.where('id > 1')
          d = Export::Dwca::Occurrence::Data.new(core_scope: s, extension_scopes: { media: media_scope })
          expect(d.media_tmp.count).to eq(2)
        end

        specify '#media_tmp sanitizes newlines and tabs in caption and description' do
          co = CollectionObject.last
          caption_with_special = "Caption\nwith newline\tand tab"
          figure_label_with_special = "Label\twith\ntab and newline"

          depiction = FactoryBot.create(:valid_depiction,
            depiction_object: co,
            caption: caption_with_special,
            figure_label: figure_label_with_special
          )

          s = scope.where('id > 1')
          d = Export::Dwca::Occurrence::Data.new(core_scope: s, extension_scopes: { media: media_scope })

          media_file = d.media_tmp
          media_file.rewind
          content = media_file.read
          rows = CSV.parse(content, col_sep: "\t", headers: true)

          # Should replace newlines and tabs with spaces
          expect(rows.first['caption']).to eq('Caption with newline and tab')
          expect(rows.first['description']).to eq('Label with tab and newline')
        end

        specify '#media_tmp includes attribution data (owner, creator, copyright)' do
          co = CollectionObject.last
          depiction = FactoryBot.create(:valid_depiction, depiction_object: co)
          image = depiction.image

          attribution = FactoryBot.create(:valid_attribution,
            attribution_object: image,
            copyright_year: 2024
          )

          person1 = FactoryBot.create(:valid_person, last_name: 'Doe', first_name: 'John')
          person2 = FactoryBot.create(:valid_person, last_name: 'Smith', first_name: 'Jane')

          AttributionOwner.create!(role_object: attribution, person: person1, project_id: attribution.project_id)
          AttributionCreator.create!(role_object: attribution, person: person2, project_id: attribution.project_id)

          s = DwcOccurrence.where(dwc_occurrence_object_id: co.id, dwc_occurrence_object_type: 'CollectionObject')
          co_sql = CollectionObject.where(id: co.id).to_sql
          d = Export::Dwca::Occurrence::Data.new(core_scope: s, extension_scopes: { media: { collection_objects: co_sql, field_occurrences: nil } })

          rows = CSV.parse(d.media_tmp, col_sep: "\t", headers: true)

          our_row = rows.find { |r| r['providerManagedID'] == image.id.to_s }
          expect(our_row['Owner']).to match(/Doe/)
          expect(our_row['dc:creator']).to match(/Smith/)
          # No AttributionCopyrightHolder role, so no copyright.
          expect(our_row['Credit']).to eq(nil)
        end

        specify '#media_tmp includes organization attribution data' do
          co = CollectionObject.last
          depiction = FactoryBot.create(:valid_depiction, depiction_object: co)
          image = depiction.image

          # Create attribution with copyright year and organization-based roles
          attribution = FactoryBot.create(:valid_attribution,
            attribution_object: image,
            copyright_year: 2025
          )

          # Create organizations for owner and copyright holder
          # Note: AttributionCreator only allows people, not organizations
          org_owner = FactoryBot.create(:valid_organization, name: 'Test Museum')
          org_copyright = FactoryBot.create(:valid_organization, name: 'Illinois Natural History Survey')

          AttributionOwner.create!(role_object: attribution, organization: org_owner, project_id: attribution.project_id)
          AttributionCopyrightHolder.create!(role_object: attribution, organization: org_copyright, project_id: attribution.project_id)

          s = DwcOccurrence.where(dwc_occurrence_object_id: co.id, dwc_occurrence_object_type: 'CollectionObject')
          co_sql = CollectionObject.where(id: co.id).to_sql
          d = Export::Dwca::Occurrence::Data.new(core_scope: s, extension_scopes: { media: { collection_objects: co_sql, field_occurrences: nil } })

          rows = CSV.parse(d.media_tmp, col_sep: "\t", headers: true)

          our_row = rows.find { |r| r['providerManagedID'] == image.id.to_s }
          expect(our_row['Owner']).to eq('Test Museum')
          expect(our_row['Credit']).to eq('©2025 Illinois Natural History Survey')
        end

        specify '#media_tmp uses UUID identifier if present' do
          co = CollectionObject.last
          depiction = FactoryBot.create(:valid_depiction, depiction_object: co)
          image = depiction.image

          identifier = FactoryBot.create(:identifier_global_uuid,
            identifier_object: image,
            is_generated: true
          )
          uuid_value = identifier.identifier

          s = scope.where('id > 1')
          d = Export::Dwca::Occurrence::Data.new(core_scope: s, extension_scopes: { media: media_scope })

          rows = CSV.parse(d.media_tmp, col_sep: "\t", headers: true)

          # Should use UUID instead of image:id
          expect(rows.first['identifier']).to eq("image:#{uuid_value}")
        end

        specify '#media_tmp includes image dimensions and format' do
          co = CollectionObject.last
          depiction = FactoryBot.create(:valid_depiction, depiction_object: co)

          s = scope.where('id > 1')
          d = Export::Dwca::Occurrence::Data.new(core_scope: s, extension_scopes: { media: media_scope })

          rows = CSV.parse(d.media_tmp, col_sep: "\t", headers: true)

          expect(rows.first['dc:type']).to eq('Image')
          expect(rows.first['PixelXDimension']).not_to be_nil
          expect(rows.first['PixelYDimension']).not_to be_nil
          expect(rows.first['dc:format']).to match(/image\/(jpeg|png|gif)/)
        end

        specify 'shortened_urls table has required columns for media export' do
          # The Shortener gem's shortened_urls table is used in lib/export/dwca/data.rb.
          # This spec ensures the gem's internal table structure hasn't changed
          # in a way that would break our media URL shortening functionality.
          connection = ActiveRecord::Base.connection

          # Verify required columns exist
          columns = connection.columns('shortened_urls').map(&:name)
          expect(columns).to include('url')
          expect(columns).to include('unique_key')
        end
      end

      context ':predicate_extensions with orphaned collection objects' do
        let(:p1) { FactoryBot.create(:valid_predicate)}
        let(:p2) { FactoryBot.create(:valid_predicate)}
        let(:p3) { FactoryBot.create(:valid_predicate)}
        let(:predicate_ids) { [p3.id, p1.id, p2.id] } # purposefully out of order

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

          a = Export::Dwca::Occurrence::Data.new(core_scope: scope, predicate_extensions: {collection_object_predicate_id: predicate_ids, collecting_event_predicate_id: predicate_ids } )

          # Orphan DwcOccurrence
          f.delete
          l.delete
          m.delete

          expect{a.predicate_data}.not_to raise_error
        end

        specify 'orders values into the right rows' do
          f = Specimen.first
          m = Specimen.third
          l = Specimen.last

          d1 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: f, predicate: p1 )
          d2 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: l, predicate: p3 )
          d3 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: m, predicate: p2 )

          c = FactoryBot.create(:valid_collecting_event)
          d4 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p1 )

          m.update!(collecting_event: c)

          a = Export::Dwca::Occurrence::Data.new(core_scope: scope, predicate_extensions: {collection_object_predicate_id: predicate_ids, collecting_event_predicate_id: predicate_ids } )

          f = a.predicate_data.read

          z = CSV.parse(f, headers: true)

          # DA row order must match DWCO row order.
          expect(z.to_a[1].first).to include(d1.value) # on 1st specimen
          expect(z.to_a[2].first).to eq("\t\t\t") # on 2nd specimen
          expect(z.to_a[3].first).to include(d4.value) # the ce value, on 3rd specimen
          expect(z.to_a[3].first).to include(d3.value) # on 3rd specimen
          expect(z.to_a[4].first).to eq("\t\t\t") # on 4th specimen
          expect(z.to_a[5].first).to include(d2.value) # on 5th specimen
        end

        specify 'destruction of DataAttribute post-instantiation is caught' do
          f = Specimen.first

          d1 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: f, predicate: p2 )

          c = FactoryBot.create(:valid_collecting_event)
          d2 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p1 )

          f.update!(collecting_event: c)

          a = Export::Dwca::Occurrence::Data.new(core_scope: scope, predicate_extensions: {collection_object_predicate_id: predicate_ids, collecting_event_predicate_id: predicate_ids } )

          d1.destroy!
          d2.destroy!

          expect{a.predicate_data}.not_to raise_error
        end

        specify 'predicate data rows match dwc_occurrence order not collection_object.id order' do
          # This tests that when collection_object.id order differs from
          # dwc_occurrence.id order, the predicate_data follows dwc_occurrence
          # order (matching the core data file).

          s1 = Specimen.order(:id).first
          s2 = Specimen.order(:id).second
          s3 = Specimen.order(:id).third

          # Force dwc_occurrence order to differ from collection_object order
          # by destroying and recreating the first specimen's dwc_occurrence.
          s1.dwc_occurrence.destroy!
          s1.get_dwc_occurrence

          d1 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: s1, predicate: p1, value: 'specimen_1_value')
          d2 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: s2, predicate: p1, value: 'specimen_2_value')
          d3 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: s3, predicate: p1, value: 'specimen_3_value')

          # Now dwc_occurrence order should be: s2, s3, s1 (s1's dwc was recreated last)
          # But collection_object order is still: s1, s2, s3

          a = Export::Dwca::Occurrence::Data.new(core_scope: scope, predicate_extensions: {collection_object_predicate_id: [p1.id]})

          predicate_csv = a.predicate_data.read
          rows = CSV.parse(predicate_csv, headers: true, col_sep: "\t")

          # Get all values from the predicate column
          predicate_column_index = rows.headers.index("TW:DataAttribute:CollectionObject:#{p1.name}")
          values_in_order = rows.map { |row| row[predicate_column_index] }

          # Order should be s2, s3, s1 (based on dwc_occurrence.id order)
          s2_index = values_in_order.index('specimen_2_value')
          s3_index = values_in_order.index('specimen_3_value')
          s1_index = values_in_order.index('specimen_1_value')

          expect(s2_index).to be < s3_index
          expect(s3_index).to be < s1_index
        end

        specify 'predicate_data excludes empty columns when some configured predicates are unused' do
          f = Specimen.first

          c = FactoryBot.create(:valid_collecting_event)
          f.update!(collecting_event: c)

          # Only create data for p1 and p3, not p2
          d1 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p1 )
          d2 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p3 )

          # Configure all 3 predicates but only 2 have data
          a = Export::Dwca::Occurrence::Data.new(core_scope: scope, predicate_extensions: {collecting_event_predicate_id: predicate_ids } )

          content = a.predicate_data.read

          headers = content.lines.first.strip.split("\t")

          # Should only have columns for predicates with data (p1 and p3), not p2.
          expect(headers).to contain_exactly(
            "TW:DataAttribute:CollectingEvent:#{p1.name}",
            "TW:DataAttribute:CollectingEvent:#{p3.name}"
          )
        end

        specify 'predicate_data sanitizes newlines and tabs in values' do
          f = Specimen.first

          c = FactoryBot.create(:valid_collecting_event)
          f.update!(collecting_event: c)

          value_with_newline = "Line 1\nLine 2\nLine 3"
          value_with_tab = "Column1\tColumn2\tColumn3"
          value_with_both = "Text with\ttab and\nnewline"

          d1 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p1, value: value_with_newline)
          d2 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p2, value: value_with_tab)
          d3 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p3, value: value_with_both)

          a = Export::Dwca::Occurrence::Data.new(core_scope: scope,
            predicate_extensions: {collecting_event_predicate_id: predicate_ids } )

          content = a.predicate_data.read

          # Parse as TSV with CSV parser (handles quoted fields)
          rows = CSV.parse(content, col_sep: "\t", headers: true)

          expect(rows.first["TW:DataAttribute:CollectingEvent:#{p1.name}"]).to eq("Line 1 Line 2 Line 3")
          expect(rows.first["TW:DataAttribute:CollectingEvent:#{p2.name}"]).to eq("Column1 Column2 Column3")
          expect(rows.first["TW:DataAttribute:CollectingEvent:#{p3.name}"]).to eq("Text with tab and newline")
        end
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

            d = Export::Dwca::Occurrence::Data.new(core_scope: scope, taxonworks_extensions: [:otu_name])

            e = d.taxonworks_extension_data.read

            z = CSV.parse(e, headers: true)

            expect(z.to_a[1].first).to eq(d1.otu.name)
            expect(z.to_a[2].first).to eq(nil)
            expect(z.to_a[3].first).to eq(d3.otu.name)
            expect(z.to_a[4].first).to eq(nil)
            expect(z.to_a[5].first).to eq(d2.otu.name)
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

            d = Export::Dwca::Occurrence::Data.new(core_scope: scope, taxonworks_extensions: [:elevation_precision])

            e = d.taxonworks_extension_data.read

            z = CSV.parse(e, headers: true)

            expect(z.to_a[1].first).to eq(c1.elevation_precision)
            expect(z.to_a[2].first).to eq(nil)
            expect(z.to_a[3].first).to eq(c3.elevation_precision)
            expect(z.to_a[4].first).to eq(nil)
            expect(z.to_a[5].first).to eq(c2.elevation_precision)
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

            d = Export::Dwca::Occurrence::Data.new(core_scope: scope, taxonworks_extensions: [:otu_name, :elevation_precision])

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

            d = Export::Dwca::Occurrence::Data.new(
              core_scope: scope.where(dwc_occurrence_object_id: [s1.id, s3.id, s2.id]),
              taxonworks_extensions: ::CollectionObject::DwcExtensions::TaxonworksExtensions::EXTENSION_FIELDS
            )

            s2.dwc_occurrence.delete # !!

            qq = FactoryBot.create(:valid_asserted_distribution,
              asserted_distribution_object: o1)

            e = d.taxonworks_extension_data.read

            z = CSV.parse(e, headers: true)

            # TODO: proper ids!!
            expect(z.to_a).to eq(
              [
                ["TW:Internal:otu_name\tTW:Internal:collecting_event_id\tTW:Internal:elevation_precision\tTW:Internal:collection_object_id\tTW:Internal:dwc_occurrence_id"],
                ["\t#{c1.id}\t1.0\t#{s1.id}\t#{s1.dwc_occurrence.id}"],  # 1
                ["aus\t#{c2.id}\t2.0\t#{s3.id}\t#{s3.dwc_occurrence.id}"] # 5
              ]
            )
          end

          specify 'uses canonical extension header order regardless of input order' do
            extensions = ::CollectionObject::DwcExtensions::TaxonworksExtensions::EXTENSION_FIELDS

            # Pass them in reverse order to simulate a caller shuffling things
            d = Export::Dwca::Occurrence::Data.new(
              core_scope: scope,
              taxonworks_extensions: extensions.reverse
            )

            e = d.taxonworks_extension_data.read
            z = CSV.parse(e, headers: true)

            expected_header = extensions.map { |sym| "TW:Internal:#{sym}" }.join("\t")

            expect(z.to_a.first.first).to eq(expected_header)
          end
        end

        context 'exporting otu_name' do
          let(:d) {Export::Dwca::Occurrence::Data.new(core_scope: scope, taxonworks_extensions: [:otu_name])}
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

          context 'handling two taxon_determinations on a collection object with position 1' do
            # Regression specs: there should never be a collection object with
            # two taxon determinations with position=1, but there have been.
            specify 'query includes remediation' do
              specimen = Specimen.first
              otu1 = Otu.create!(name: 'first_otu')
              otu2 = Otu.create!(name: 'second_otu')

              td1 = TaxonDetermination.create!(
                otu: otu1,
                taxon_determination_object: specimen,
              )

              td2 = TaxonDetermination.create!(
                otu: otu2,
                taxon_determination_object: specimen
              )
              td2.update_columns(position: 1)
              #ActiveRecord::Base.connection.execute(
              #  "UPDATE taxon_determinations SET position = 1 WHERE id IN (#{td1.id}, #{td2.id})"
              #)

              # Verify the bug scenario: duplicate position=1 TDs
              expect(TaxonDetermination.where(
                taxon_determination_object: specimen,
                position: 1
              ).count).to eq(2)
              expect(td2.id).to be > td1.id

              # Export should select the taxon_determination with the higher id.
              # !! Yes, it's possible this could pass by chance sometimes (it
              # should *never* fail though)! See next spec as well .
              export_scope = DwcOccurrence.where(dwc_occurrence_object: specimen)
              export = Export::Dwca::Occurrence::Data.new(core_scope: export_scope, taxonworks_extensions: [:otu_name])
              result = CSV.parse(export.taxonworks_extension_data.read, headers: true)

              expect(result.first['TW:Internal:otu_name']).to eq('second_otu')
            end

            specify 'query orders taxon_determinations by id DESC for deterministic selection' do
              # Verify the SQL query includes ORDER BY with id DESC to handle
              # duplicate position=1 taxon determinations.
              export_scope = DwcOccurrence.where(dwc_occurrence_object_type: 'CollectionObject')
              exporter = Export::Dwca::Occurrence::TaxonworksExtensionExporter.new(
                core_scope: export_scope,
                taxonworks_extension_methods: [:otu_name]
              )

              query_data = exporter.send(:extension_data_query_data)
              sql = query_data[:query].to_sql

              # Somwhat brittle, somewhat imperfect. If it breaks in a year or
              # two and these two specs haven't been an issue, we can probably
              # just remove it.
              expect(sql).to match(/FROM taxon_determinations.*ORDER BY.*\.id DESC/m)
              expect(sql).to include('position = 1')
            end
          end

        end

        context 'exporting header with different api column name' do
          let(:d) { Export::Dwca::Occurrence::Data.new(core_scope: scope, taxonworks_extensions: [:collection_object_id]) }

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
          let(:d) { Export::Dwca::Occurrence::Data.new(core_scope: scope, taxonworks_extensions: [:elevation_precision]) }
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

        context 'exporting dwc_occurrence.id' do
          let(:d) { Export::Dwca::Occurrence::Data.new(core_scope: scope, taxonworks_extensions: [:dwc_occurrence_id]) }

          specify 'should have the dwc_occurrence_id in the correct extension file row' do
            expect(File.readlines(d.taxonworks_extension_data).last&.strip).to eq(CollectionObject.last.dwc_occurrence.id.to_s)
          end

          specify 'should have the dwc_occurrence_id in the combined file' do
            expect(File.readlines(d.all_data).last).to include(CollectionObject.last.dwc_occurrence.id.to_s)
          end
        end

        context 'when no extensions are selected' do
          let(:empty_extension) { Export::Dwca::Occurrence::Data.new(core_scope: scope, taxonworks_extensions: []) }

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
        expect(csv.count).to eq(5) # 5 data rows
      end

      specify '#csv sanitizes newlines and tabs in locality field' do
        locality_with_special_chars = "Site A\nElevation: 1000m\tCoordinates: 45.5, -122.6"
        ce = FactoryBot.create(:valid_collecting_event,
          verbatim_locality: locality_with_special_chars)
        specimen = FactoryBot.create(:valid_specimen, collecting_event: ce)
        dwc = specimen.get_dwc_occurrence

        # Update the verbatimLocality directly in the database to have newlines/tabs
        # using update_column to bypass callbacks and set the raw value.
        dwc.update_column(:verbatimLocality, locality_with_special_chars)

        # Verify it was set.
        dwc.reload
        expect(dwc.read_attribute(:verbatimLocality)).to eq(locality_with_special_chars)

        # Export just this specimen.
        single_scope = DwcOccurrence.where(id: dwc.id)
        single_export = Export::Dwca::Occurrence::Data.new(core_scope: single_scope)

        csv_output = CSV.parse(single_export.data.read, headers: true, col_sep: "\t")

        expect(csv_output.first['verbatimLocality']).to eq("Site A Elevation: 1000m Coordinates: 45.5, -122.6")
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
