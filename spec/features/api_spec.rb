require 'rails_helper'

describe ApiController, :type => :feature do 

  context 'GET /api using browser address bar', js: true do
    let(:user) { FactoryGirl.create(:valid_user, :user_valid_token) }

    context 'with a valid token' do
    let(:user) { FactoryGirl.create(:valid_user, :user_valid_token) }

      it 'shows a JSON success response' do
        visit api_path + "?project_id=1&token=#{user.api_access_token}" 
          # NOTE: using "find" because js:true causes the response to be wrapped inside an html document
          expect(JSON.parse(find('pre').text)).to eq({ "success" => true })
      end
    end

    context 'with an invalid token' do

      it 'shows a JSON failure response' do
        visit api_path + "?project_id=1&token=FOO" 
          # NOTE: using "find" because js:true causes the response to be wrapped inside an html document
          expect(JSON.parse(find('pre').text)).to eq({ "success" => false })
      end
    end
  end
end
