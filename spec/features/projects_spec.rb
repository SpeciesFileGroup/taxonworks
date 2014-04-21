require 'spec_helper'

describe 'Project Handling' do

  subject { page }

  describe '/' do

    before {
      sign_in_valid_user
    }

    context 'when a user is signed in they see a list of projects (in the hub)' do
      it 'should have a list of project links' do 
        subject.should have_link('My Project', href: select_project_path(Project.find(1)) )
      end
    end

    context 'when user clicks a project link' do
      before(:each) {
        click_link 'My Project' 
      }

      it 'should select that project' do
       subject.should have_link('My Project', href: select_project_path(Project.find(1)) )
 
       expect($user_id).to eq(1)
       expect($project_id).to eq(1)
        #       Capybara
        #       .current_session # Capybara::Session
        #       .driver          # Capybara::RackTest::Driver
        #       .request         # Rack::Request
        #       .cookies         # { "author" => "me" }
        #       .[]('author').should_not be_nil

        #  Capybara.current_session.driver.request.cookies.[]('auth_token').should_not be_nil
        #  auth_token_value = Capybara.current_session.driver.request.cookies.[]('auth_token')
        #  Capybara.reset_sessions!
        #  page.driver.browser.set_cookie("auth_token=#{auth_token_value}")

      end

      it 'should render the default_workspace_path' do
        subject.should have_content "OTUs"
      end

    end
  end
end

