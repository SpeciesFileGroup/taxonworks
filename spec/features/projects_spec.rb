require 'spec_helper'

describe 'Project Handling' do

  subject { page }

  # TODO: clarify this, this is describing the root path but under Projects
  describe '/' do
  
    before(:each) {
      $user_id = nil 
      $project_id = nil
      sign_in_valid_user
    }

    after(:all) {
      $project_id = 1
      $user_id = 1
    }

    context 'when a user is signed in they see a list of projects (in the hub)' do
      it 'should have a list of project links' do 
        subject.should have_link('My Project', href: select_project_path(Project.find(1)) )
        subject.should have_css("a", text: 'My Project' )
      end
    end

    context 'when user clicks a project link' do
      before(:each) {
        click_link 'My Project' 
      }

      it 'should select that project' do
        subject.should have_link('My Project', href: select_project_path(Project.find(1)) )
        subject.should have_css("mark a", text: 'My Project' )
      end

      it 'should render the default_workspace_path' do
        subject.should have_content "OTUs"
      end
    end

    context 'when user clicks logout' do
      before(:each) {
        click_link 'Sign out'
      }

      it 'should unselect the project when logged back in' do
        sign_in_valid_user
        visit root_path
        subject.should have_no_css("mark a", text: 'My Project' )
        subject.should have_css("a", text: 'My Project' )
      end

    end

  end
end

