require 'rails_helper'

describe 'Api::V1::Leads', type: :request do

  context 'leads/index' do
    include_context 'api context'

    let(:source) { FactoryBot.create(:valid_source_bibtex, by: user) }

    let!(:key) { FactoryBot.create(:valid_lead, is_public: true, by: user, project:) }
    let!(:citation) { FactoryBot.create(:valid_citation, citation_object: key, source:, by: user, project:) }
    let!(:uncited_key) { FactoryBot.create(:valid_lead, text: 'Uncited key.', is_public: true, by: user, project:) }

    let!(:simple_key) { FactoryBot.create(:valid_lead, text: 'Simple key.', is_virtual: true, is_public: true, by: user, project:) }
    let!(:simple_key_citation) { FactoryBot.create(:valid_citation, citation_object: simple_key, source:, by: user, project:) }

    let(:rendered_leads) { JSON.parse(response.body) }
    let(:rendered_key) { rendered_leads.find { |l| l['id'] == key.id } }
    let(:rendered_uncited_key) { rendered_leads.find { |l| l['id'] == uncited_key.id } }
    let(:rendered_simple_key) { rendered_leads.find { |l| l['id'] == simple_key.id } }

    context 'without extend[]=citations' do
      before { get '/api/v1/leads', headers:, params: { project_id: project.id } }

      it_behaves_like 'a successful response'

      it 'returns the key' do
        expect(rendered_key).to be_present
      end

      it 'excludes the citations key' do
        expect(rendered_key).not_to have_key('citations')
      end
    end

    context 'with extend[]=citations' do
      before { get '/api/v1/leads', headers:, params: { project_id: project.id, extend: ['citations'] } }

      it_behaves_like 'a successful response'

      it 'includes the cited source' do
        expect(rendered_key['citations'].map { |c| c['source_id'] }).to eq([citation.source_id])
      end

      it 'returns an empty citations array for a key without citations' do
        expect(rendered_uncited_key['citations']).to eq([])
      end
    end

    context 'with is_virtual=true and extend[]=citations' do
      before { get '/api/v1/leads', headers:, params: { project_id: project.id, is_virtual: true, extend: ['citations'] } }

      it 'includes the simple key citation' do
        expect(rendered_simple_key['citations'].map { |c| c['id'] }).to eq([simple_key_citation.id])
      end
    end

    context 'with is_virtual=all and extend[]=citations' do
      before { get '/api/v1/leads', headers:, params: { project_id: project.id, is_virtual: 'all', extend: ['citations'] } }

      it 'includes citations for both key types' do
        expect([rendered_key, rendered_simple_key].map { |l| l['citations'].size }).to eq([1, 1])
      end
    end
  end
end
