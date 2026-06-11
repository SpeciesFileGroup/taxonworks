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

    context 'with extend[]=descendants' do
      let(:family) do
        Protonym.create!(name: 'Aidae', rank_class: Ranks.lookup(:iczn, :family), parent: project.root_taxon_name, by: user, project: project)
      end

      let!(:genus) do
        Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: family, by: user, project: project)
      end

      before { get "/api/v1/taxon_names/#{family.id}/monograph", headers: headers, params: { project_id: project.id, extend: ['descendants'] } }

      it_behaves_like 'a successful response'

      it 'returns an array' do
        expect(JSON.parse(response.body)).to be_an Array
      end

      it 'includes each descendant' do
        ids = JSON.parse(response.body).map { |t| t['id'] }
        expect(ids).to include(genus.id)
      end

      it 'does not include the root taxon itself' do
        ids = JSON.parse(response.body).map { |t| t['id'] }
        expect(ids).not_to include(family.id)
      end

      context 'when descendant count exceeds 2500' do
        before do
          allow_any_instance_of(TaxonName).to receive_message_chain(:descendants, :count).and_return(2501)
          get "/api/v1/taxon_names/#{family.id}/monograph", headers: headers, params: { project_id: project.id, extend: ['descendants'] }
        end

        it_behaves_like 'a successful response'

        it 'returns an empty array' do
          expect(JSON.parse(response.body)).to eq []
        end
      end
    end
  end
end
