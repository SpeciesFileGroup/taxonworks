require 'rails_helper'

describe Api::V1::BaseController, type: :request do

  context :index do
    let!(:project) { FactoryBot.create(:valid_project, :project_valid_token) } 
    let(:path) { '/api/v1/' }

    before { get path  }

    it_behaves_like 'a successful response'

    specify 'open_projects' do
      expect(JSON.parse(response.body).dig('open_projects')).to contain_exactly([{project.api_access_token => project.name}])
    end
  end
end
