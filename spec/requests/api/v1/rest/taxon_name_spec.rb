require 'rails_helper'

describe 'Api::V1::TaxonNames', type: :request do

  context 'taxon_names' do

    # let(:taxon_name) { FactoryBot.create(:valid_taxon_name) }
    # let(:headers) { { "Authorization": 'Token token=' + user.api_access_token, project_id: taxon_name.project_id } }
    # let(:path) { '/api/v1/taxon_names/' }

    it_behaves_like 'secured by user and project token', :valid_taxon_name, '/api/v1/taxon_names/'
  end

  context 'taxon_names/autocomplete' do

    it_behaves_like 'secured by user and project token', :valid_taxon_name, '/api/v1/taxon_names/autocomplete'
  end
end
