require 'rails_helper'

describe 'Api::V1::TaxonNames', type: :request do
  context 'taxon_names' do

    # let(:taxon_name) { FactoryBot.create(:valid_taxon_name) }
    # let(:headers) { { "Authorization": 'Token token=' + user.api_access_token, project_id: taxon_name.project_id } }
    # let(:path) { '/api/v1/taxon_names/' }

    it_behaves_like 'secured by user/project token', :valid_taxon_name, '/api/v1/taxon_names/'
  end

  context 'taxon_names/autocomplete' do
    it_behaves_like 'secured by user/project token', :valid_taxon_name, '/api/v1/taxon_names/autocomplete'
  end

  context 'taxon_names/:id/monograph' do
    include_context 'api context'

    let(:taxon_name) do
      Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: project.root_taxon_name, by: user, project: project)
    end

    before { get "/api/v1/taxon_names/#{taxon_name.id}/monograph", headers: headers, params: { project_id: project.id } }

    it_behaves_like 'a successful response'
  end
end
