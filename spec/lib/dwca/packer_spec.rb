require 'rails_helper'
require 'dwca/packer'

describe Dwca::Packer::Data, type: :model do 
  let(:scope) { DwcOccurrence.all }

  specify 'initializing without a scope raises' do
    expect {Dwca::Packer::Data.new(nil)}.to raise_error ArgumentError 
  end

  specify 'initializing with a DwcOccurrence scope succeeds' do
    expect(Dwca::Packer::Data.new(scope)).to be_truthy
  end

   context 'when initialized with a scope' do
    let(:data) { Dwca::Packer::Data.new(scope) }

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

      after do
        data.cleanup
      end

      let(:csv) { CSV.parse(data.csv, headers: true, col_sep: "\t") }
      let(:headers) { ['basisOfRecord', 'individualCount' ] }  

      context 'various scopes' do
        specify 'with .where clauses' do
          s = scope.where('id > 1')
          d = Dwca::Packer::Data.new(s)
          expect(d.csv_headers).to contain_exactly(*headers)
        end

        specify 'with .order clauses' do
          s = scope.order(:basisOfRecord)
          d = Dwca::Packer::Data.new(s)
          expect(d.csv_headers).to contain_exactly(*headers)
        end

        specify 'with .join clauses' do
          s = scope.collection_objects_join
          d = Dwca::Packer::Data.new(s)
          expect(d.csv_headers).to contain_exactly(*headers)
        end
      end

      specify '#csv returns lines for specimens' do
        expect(csv.count).to eq(5)
      end

      specify 'TW housekeeping columns are not present' do
        expect(csv.headers).not_to include('project_id', 'created_by_id', 'updated_by_id')
      end

      specify 'generated headers are restricted to data' do
        expect(csv.headers).to contain_exactly('id', 'basisOfRecord', 'individualCount') 
      end

      specify '#csv_headers can be returned, and exclude id' do
        expect(data.csv_headers).to contain_exactly(*headers) 
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

        specify '#getzip is a zipfile string' do
          expect(data.getzip).to be_kind_of(String) 
        end
      end

      # TODO: actually check tempfile directory
      specify '#cleanup' do
        expect(data.cleanup).to be_truthy
      end
    end

  end
end
