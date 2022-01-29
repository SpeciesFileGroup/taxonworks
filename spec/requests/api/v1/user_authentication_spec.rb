require 'rails_helper'

describe 'UserAuthentication', type: :request do

  let(:path) { '/api/v1/user_authenticated' }

  context 'when token is valid' do
    let(:user) { FactoryBot.create(:valid_user, :user_valid_token) }
    let(:params) { { token: user.api_access_token } }  # { {project_id: 1, format: :json} }
    let(:headers) { { "Authorization": 'Token token=' + user.api_access_token } }

    context 'when provided in header' do
      before { get path, headers: headers }
      it_behaves_like 'a successful response'
    end

    context 'when provided in query params' do
      before { get path, params: params }
      it_behaves_like 'a successful response'
    end
  end

  context 'when token is invalid' do
    let(:user) { FactoryBot.create(:valid_user, :user_valid_token) }
    let(:params) { { } }
    let(:headers) { { "Authorization": 'Token token=' + 'FOO' }   }

    context 'when provided in header' do
      before { get path, headers: headers }
      it_behaves_like 'unauthorized response'
    end

    context 'when provided in query params' do
      before { get path, params: {token: 'foo'}.merge(params)}

      it_behaves_like 'unauthorized response'
    end

    context 'when not provided' do
      before { get path, **params }
      it_behaves_like 'unauthorized response'
    end
  end
end
