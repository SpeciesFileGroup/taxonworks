require 'spec_helper'

describe 'Project Handling' do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { projects_path }
    let(:page_index_name) { 'Dashboard' }
  end

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

  describe 'GET /projects' do
    context 'without admin login' do 
      before { 
        sign_in_valid_user
        visit projects_path 
      }
      it 'should redirect to hub and present a notice'
    end

    context 'with admin login' do
      before {
        sign_in_administrator
        visit projects_path 
      }
      it 'should render a list of projects'
    end
  end

  describe 'GET /projects/1' do
    context 'logged in member is a member and project admin' do 
      before { 
        sign_in_valid_user
        visit projects_path 
      }
      it 'should show the project'
    end

    context 'with admin, non-member login' do
      before {
        sign_in_administrator
        visit projects_path 
      }
      it 'it should show the project'
    end
  end


  describe 'GET /projects/1/edit' do
    context 'logged in member is a member and project admin' do 
      before { 
        sign_in_valid_user
        visit projects_path 
      }
      it 'should render the edit form'
    end

    context 'with admin, non-member login' do
      before {
        sign_in_administrator
        visit projects_path 
      }
      it 'should render the edit form'
    end

    context 'with non-superuser project member' do
      before {
        sign_in_administrator
        visit projects_path 
      }
      it 'should redirect to hub and present a notice'
    end


  end





end

