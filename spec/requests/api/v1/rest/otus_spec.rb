require 'rails_helper'

describe 'Api::V1::Otus', type: :request do

  let(:user) { FactoryBot.create(:valid_user, :user_valid_token) }

  context 'otu/index' do

    let!(:otu) { Otu.create!(name: 'Foo') } 
    let(:headers) { { "Authorization": 'Token token=' + user.api_access_token, project_id: otu.project_id } }
    let(:path) { '/api/v1/otus/' }

    context 'without a user token' do
      before { get path } 
      it_behaves_like 'unauthorized response'
    end

    context 'with a valid user token, without project_id' do
      before { get path, headers: headers } 
      it_behaves_like 'unauthorized response'
    end

    context 'with a valid user token and project_id' do
      before { get path, headers: headers, params: { project_id: otu.project_id } } 
      it_behaves_like 'a successful response'
    end

    context 'with a valid user token and valid project token (project set by proxy)' do
      before { otu.project.update(set_new_api_access_token: true) }
      before { get path, headers: headers, params: { project_id: otu.project.api_access_token } } 
      it_behaves_like 'a successful response'
    end

  end
end
