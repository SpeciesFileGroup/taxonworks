require 'rails_helper'

describe 'API', type: :feature do 

  context 'GET /api' do
    let(:user) { FactoryGirl.create(:valid_user) }

    context 'with a valid token' do
      before {
        user.generate_api_access_token
        user.save

        Capybara.current_session.driver.header('Authorization' , "Token token=\"#{user.api_access_token}\"") 
      }

      context 'html' do
        before {visit api_path}

        specify 'then I see a list of endpoints' do
          expect(page).to have_content('Endpoints')
        end

      end

      # curl -v -H 'Accept: application/json' -H "Authorization: Token token=8mU2_YotjbdvS7AgbYBPig" http://127.0.0.1:3000/api/v1/project/1/images/65

      context 'json (via HEADER)' do

        before {
          Capybara.current_session.driver.header('Accept' , 'application/json') 
          visit api_path 
        }

        specify 'then I get a json response with a list of endpoints' do
          expect(JSON.parse( page.source ) ).to be_truthy
        end
      end
    end

  end

end
