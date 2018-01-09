require 'rails_helper'

describe TaxonWorks::Vendor::Biodiversity do
  context 'Result' do

    let(:result) { TaxonWorks::Vendor::Biodiversity::Result.new }

    specify '#query_string' do
      expect( result.query_string = 'Aus bus').to be_truthy
    end

    specify '#project_id' do
      expect( result.project_id = 1 ).to be_truthy
    end

    context 'parsing' do
      before { result.query_string = 'Aus bus' }

      specify '#parse_result' do
        expect(result.parse_result[:scientificName]).to be_truthy
      end

    end

  end

end 





