require 'rails_helper'

describe 'ProjectAuthentication', type: :request do

  let(:path) { '/api/v1/project_authenticated' }

  let(:user) { FactoryBot.create(:valid_user) }

  context 'when token is valid' do
    let(:project) { FactoryBot.create(:valid_project, :project_valid_token, by: user, name: 'definitely not this either') }
    let(:params) { { project_token: project.api_access_token } }  # { {project_id: 1, format: :json} }
    let(:headers) { { "Project token": project.api_access_token } }

    context 'when provided in header' do
      before { get path, headers: headers }
      it_behaves_like 'a successful response'
    end

    context 'when provided in query params' do
      before { get path, params: params }
      it_behaves_like 'a successful response'
    end

    context 'when project_token and project_id params in agreement' do
      before { get path, params: params.merge(project_id: project.id) }
      it_behaves_like 'a successful response'
    end

    context 'when project_token and project_id params in conflict' do
      let!(:project2) { FactoryBot.create(:valid_project, by: user, name: 'definitely not this') }
      before { get path, params: params.merge(project_token: project.api_access_token, project_id: project2.id) }
      it_behaves_like 'unauthorized response'
    end
  end

  context 'when token is invalid' do
    let(:params) { { } }
    let(:headers) { { 'Project token':  'FOO' } }

    context 'when provided in header' do
      before { get path, headers: headers }
      it_behaves_like 'unauthorized response'
    end

    context 'when provided in query params' do
      before { get path, params: {project_token: 'foo'}.merge(params)}
      it_behaves_like 'unauthorized response'
    end

    context 'when not provided' do
      before { get path, **params }
      it_behaves_like 'unauthorized response'
    end
  end
end
