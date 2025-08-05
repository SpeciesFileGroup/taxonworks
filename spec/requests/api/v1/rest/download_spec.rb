require 'rails_helper'

describe 'Api::V1::Downloads', type: :request do
  context 'Download::DwcArchive::Complete' do
    include_context 'api context'

    context 'build' do
      context 'with allowed type' do
        it_behaves_like 'secured by user/project token', nil, '/api/v1/downloads/build?type=Download::DwcArchive::Complete', 'post', 'require_user_and_project_tokens'
      end

      context 'with unallowed type fails' do
        it_behaves_like 'unprocessable entity', nil, '/api/v1/downloads/build?type=Download::DwcArchive', 'post', 'require_user_and_project_tokens'
      end

      specify 'must be admin user to start a build' do
        user2 = FactoryBot.create(:valid_user, :user_valid_token) # not admin
        headers = { "Authorization": 'Token ' + user2.api_access_token }

        post "/api/v1/downloads/build?type=Download::DwcArchive::Complete", headers: headers, params: { project_token: project.api_access_token }

        expect(response.status).to eq(422)
      end
    end

    context 'delete complete' do
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

      specify 'must be admin user to delete a download' do
        user2 = FactoryBot.create(:valid_user, :user_valid_token) # not admin
        headers = { "Authorization": 'Token ' + user2.api_access_token }

        delete "/api/v1/downloads/#{d.id}", headers: headers, params: { project_token: project.api_access_token }
        expect(response.status).to eq(422)
      end
    end
  end
end
