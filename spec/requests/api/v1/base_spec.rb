require 'rails_helper'

describe Api::V1::BaseController, type: :request do

  context :index do
    let!(:project) { FactoryBot.create(:valid_project, :project_valid_token) } 
    let(:path) { '/api/v1/' }

    before { get path  }

    it_behaves_like 'a successful response'

    specify 'open_projects' do
      expect(JSON.parse(response.body).dig('open_projects')).to contain_exactly({project.api_access_token => project.name})
    end
  end

  context 'Invalid path' do
    let(:path) { '/api/v1/this-path-does-not-exist' }

    before { get path  }

    specify 'status' do
      expect(response).to be_not_found
    end

    specify 'message' do
      expect(JSON.parse(response.body)['message']).to eq('Invalid route')
    end
  end
end
