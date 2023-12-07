require 'rails_helper'
require 'export/dwca/data'

describe Export::Dwca::Data, type: :model, group: :darwin_core do
  let(:scope) { ::DwcOccurrence.all }

  specify 'initializing without a scope raises' do
    expect {Export::Dwca::Data.new()}.to raise_error ArgumentError
  end

  specify 'initializing with a DwcOccurrence scope succeeds' do
    expect(Export::Dwca::Data.new(core_scope: scope)).to be_truthy
  end

  context 'when initialized with a scope' do
    let(:data) { Export::Dwca::Data.new(core_scope: scope) }

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
        let!(:ba1) { BiologicalAssociation.create!(biological_relationship: biological_relationship, biological_association_subject: CollectionObject.first, biological_association_object: CollectionObject.last) }
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
