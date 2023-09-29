require 'rails_helper'

describe Api::V1::BaseController, type: :request do

  context :index do
    let(:user) { FactoryBot.create(:valid_user, :user_valid_token) }
    let!(:project) { FactoryBot.create(:valid_project, :project_valid_token, by: user, name: 'Something really new') }
    let(:path) { '/api/v1/' }

    before { get path  }

    it_behaves_like 'a successful response'

    specify 'open_projects #name' do
      expect(JSON.parse(response.body).dig('open_projects').first).to include({'name' => project.name})
    end

    specify 'open_projects #project_token' do
      expect(JSON.parse(response.body).dig('open_projects').first).to include({'project_token' => project.api_access_token})
    end

    specify 'open_projects #data_curation_issue_tracker_url' do
      expect(JSON.parse(response.body).dig('open_projects').first).to include({'data_curation_issue_tracker_url' => nil})
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
