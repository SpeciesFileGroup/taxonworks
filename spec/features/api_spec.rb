require 'rails_helper'

describe ApiController, type: :feature do 

  # We maintain these few feature tests to ensure browser based calls also authenticate.
  # See /requests for all other API tests.
  context 'GET /api using browser address bar', js: true do
    let(:user) { FactoryBot.create(:valid_user, :user_valid_token) }
    let(:project) { FactoryBot.create(:valid_project, :project_valid_token, by: user) }

    context 'user tokens' do
      let(:path) { '/api/v1/user_authenticated' }
      context 'with a valid token' do
        it 'shows a JSON success response' do
          visit path + "?token=#{user.api_access_token}"
          expect((find('.objectBox').text)).to eq('true')
        end
      end

      context 'with an invalid token' do

        it 'shows a JSON failure response' do
          visit path + '?token=FOO'
          expect((find('.objectBox').text)).to eq('false')
        end
      end
    end

    context 'project tokens' do

  let(:path) { '/api/v1/project_authenticated' }
      context 'with a valid token' do
        it 'shows a JSON success response' do
          visit path + "?project_token=#{project.api_access_token}"
          expect((find('.objectBox').text)).to eq('true')
        end
      end

      context 'with an invalid token' do

        it 'shows a JSON failure response' do
          visit path + '?project_token=FOO'
          expect((find('.objectBox').text)).to eq('false')
        end
      end

    end
  end
end
