require 'rails_helper'

describe 'Api::V1::TaxonNames', type: :request do

  context 'taxon_names/index' do

    # let(:taxon_name) { FactoryBot.create(:valid_taxon_name) }
    # let(:headers) { { "Authorization": 'Token token=' + user.api_access_token, project_id: taxon_name.project_id } }
    # let(:path) { '/api/v1/taxon_names/' }

    it_behaves_like 'secured by both user and project token', :valid_taxon_name, '/api/v1/taxon_names/'

    # project token-only for now
    xcontext 'with a valid user token and project_id' do
      before { get path, headers: headers, params: { project_id: taxon_name.project_id } }
      it_behaves_like 'a successful response'
    end

  end
end
