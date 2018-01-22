require 'rails_helper'

describe ApiController, type: :feature do 

  context 'GET /api using browser address bar', js: true do
    let(:user) { FactoryBot.create(:valid_user, :user_valid_token) }

    context 'with a valid token' do
      it 'shows a JSON success response' do
        visit api_path + "?project_id=1&token=#{user.api_access_token}" 
        expect((find('.objectBox').text)).to eq('true')
      end
    end

    context 'with an invalid token' do

      it 'shows a JSON failure response' do
        visit api_path + '?project_id=1&token=FOO' 
        expect((find('.objectBox').text)).to eq('false')
      end
    end
  end
end
