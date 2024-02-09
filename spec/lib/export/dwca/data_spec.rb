require 'rails_helper'
# require 'export/dwca/data'

describe Export::Dwca::Data, type: :model, group: :darwin_core do
  let(:scope) { ::DwcOccurrence.all }

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
          f = FactoryBot.create(:valid_specimen)
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

      context 'various scopes' do
        specify 'with .where clauses' do
          s = scope.where('id > 1')
          d = Export::Dwca::Data.new(core_scope: s)
          expect(d.meta_fields).to contain_exactly(*headers)
        end

        specify 'with .order clauses' do
          s = scope.order(:basisOfRecord)
          d = Export::Dwca::Data.new(core_scope: s)
          expect(d.meta_fields).to contain_exactly(*headers)
        end

        specify 'with .join clauses' do
          s = scope.collection_objects_join
          d = Export::Dwca::Data.new(core_scope: s)
          expect(d.meta_fields).to contain_exactly(*headers)
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

      context 'predicate_extension' do
        let(:p1) { FactoryBot.create(:valid_predicate)}
        let(:p2) { FactoryBot.create(:valid_predicate)}
        let(:p3) { FactoryBot.create(:valid_predicate)}
        let(:predicate_ids) { [p3.id, p1.id, p2.id] } # purposefully out of order

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
        end

        specify '#used_predicates' do
          f = Specimen.first

          c = FactoryBot.create(:valid_collecting_event)
          d4 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p1 )

          f.update!(collecting_event: c)

          d1 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p1 )
          d2 = FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: c, predicate: p3 )

          a = Export::Dwca::Data.new(core_scope: scope, predicate_extensions: {collecting_event_predicate_id: predicate_ids } )

          expect(a.collecting_event_attributes).to include([f.id, "TW:DataAttribute:CollectingEvent:#{p1.name}", d1.value])
          expect(a.collecting_event_attributes).to include([f.id, "TW:DataAttribute:CollectingEvent:#{p3.name}", d2.value])
        end

      end

      context 'taxonworks_extensions for internal attributes' do

        context 'exporting otu_name' do
          let(:d) {Export::Dwca::Data.new(core_scope: scope, taxonworks_extensions: [:otu_name])}
          let!(:o) {FactoryBot.create(:valid_otu)}
          let!(:det) {FactoryBot.create(:valid_taxon_determination, otu: o,
                                        biological_collection_object: DwcOccurrence.last.dwc_occurrence_object)}

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
            expect(d.meta_fields).to contain_exactly(*headers)
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
            expect(d.meta_fields).to contain_exactly(*headers)
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
            expect(empty_extension.meta_fields).to contain_exactly(*headers)
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
        expect(csv.headers).to contain_exactly(*(['id'] + headers))
      end

      specify '#meta_fields can be returned, and exclude id' do
        expect(data.meta_fields).to contain_exactly(*headers)
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
