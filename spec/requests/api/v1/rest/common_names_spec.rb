require 'rails_helper'

describe 'Api::V1::CommonNames', type: :request do

  context 'common_names' do
    it_behaves_like 'secured by user/project token', :valid_common_name, '/api/v1/common_names/'
  end

  context 'common_names/index' do
    include_context 'api context'

    let(:otu) { FactoryBot.create(:valid_otu, by: user, project:) }
    let!(:common_name) { FactoryBot.create(:valid_common_name, otu:, by: user, project:) }
    let(:source) { FactoryBot.create(:valid_source_bibtex, by: user) }
    let!(:citation) { FactoryBot.create(:valid_citation, citation_object: common_name, source:, by: user, project:) }
    let!(:uncited_common_name) { FactoryBot.create(:valid_common_name, name: 'Blue People Eater', otu:, by: user, project:) }

    let(:rendered_common_name) { JSON.parse(response.body).find { |c| c['id'] == common_name.id } }
    let(:rendered_uncited_common_name) { JSON.parse(response.body).find { |c| c['id'] == uncited_common_name.id } }

    context 'without extend[]=citations' do
      before { get '/api/v1/common_names', headers: headers, params: { project_id: project.id } }

      it_behaves_like 'a successful response'

      it 'returns the common name' do
        expect(rendered_common_name).to be_present
      end

      it 'excludes the citations key' do
        expect(rendered_common_name).not_to have_key('citations')
      end
    end

    context 'with extend[]=citations' do
      before { get '/api/v1/common_names', headers: headers, params: { project_id: project.id, extend: ['citations'] } }

      it_behaves_like 'a successful response'

      it 'includes the citations key' do
        expect(rendered_common_name).to have_key('citations')
      end

      it 'includes the cited source' do
        expect(rendered_common_name['citations'].map { |c| c['source_id'] }).to eq([citation.source_id])
      end

      it 'returns an empty citations array for a common name without citations' do
        expect(rendered_uncited_common_name['citations']).to eq([])
      end
    end
  end
end
