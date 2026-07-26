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

  context 'organizations' do
    let(:user) { FactoryBot.create(:valid_user, :user_valid_token) }
    let!(:project) { FactoryBot.create(:valid_project, :project_valid_token, by: user, name: 'Something really new') }

    let!(:organization) { Organization.create!(name: 'Some organization', by: user) }
    let!(:project_organization) {
      ProjectOrganization.create!(organization:, project:, by: user)
    }

    let!(:depiction) {
      Depiction.create!(
        depiction_object: organization,
        image: FactoryBot.create(:tiny_random_image, by: user, project:),
        project:,
        by: user
      )
    }

    specify '#organizations' do
      get '/api/v1/'
      expect(JSON.parse(response.body).dig('open_projects', 0, 'organizations', 0)).to include({'name' => organization.name})
    end

    specify 'depictions are not included by default' do
      get '/api/v1/'
      expect(JSON.parse(response.body).dig('open_projects', 0, 'organizations', 0)).not_to include('depictions')
    end

    specify 'extend[]=depictions includes the depiction' do
      get '/api/v1/', params: {extend: ['depictions']}
      expect(JSON.parse(response.body).dig('open_projects', 0, 'organizations', 0, 'depictions', 0)).to include({'id' => depiction.id})
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
