require 'rails_helper'

describe 'Api::V1::Downloads', type: :request do
  context 'Download::DwcArchive::Complete' do
    context 'build' do
      context 'with allowed type' do
        it_behaves_like 'secured by user/project token', nil, '/api/v1/downloads/build?type=Download::DwcArchive::Complete', 'post', 'require_user_and_project_tokens'
      end

      context 'with unallowed type fails' do
        it_behaves_like 'unprocessable entity', nil, '/api/v1/downloads/build?type=Download::DwcArchive', 'post', 'require_user_and_project_tokens'
      end
    end

    context 'delete complete' do
      include_context 'api context'
      let(:d) { Download::DwcArchive::Complete.create!(project:, by: user) }

      specify 'can delete complete downloads' do
        delete "/api/v1/downloads/#{d.id}", headers: headers, params: { project_token: project.api_access_token }

        expect(response.successful?).to be_truthy
      end

      specify "can't delete arbitrary downloads" do
        d = Download::DwcArchive.create!(name: 'a', filename: 'a', expires: Time.now, project:, by: user)
        delete "/api/v1/downloads/#{d.id}", headers: headers, params: { project_token: project.api_access_token }

        expect(response.status).to eq(404)
      end

      specify "can't delete complete downloads without user token" do
        delete "/api/v1/downloads/#{d.id}", params: { project_token: project.api_access_token }

        expect(response).to be_unauthorized
      end

      specify "can't delete complete downloads without project token" do
        delete "/api/v1/downloads/#{d.id}", headers: headers

        expect(response).to be_unauthorized
      end
    end
  end
end
