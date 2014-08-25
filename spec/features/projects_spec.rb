require 'rails_helper'

describe 'Project Handling', :type => :feature do

  subject { page }

  # TODO: clarify this, this is describing the root path but under Projects
  describe '/' do
  
    before(:each) {
      $user_id = nil 
      $project_id = nil
      sign_in_user
    }

    after(:all) {
      $project_id = 1
      $user_id = 1
    }

    context 'when a user is signed in they see a list of projects (in the hub)' do
      it 'should have a list of project links' do 
        expect(subject).to have_link('My Project', href: select_project_path(@project) )
        expect(subject).to have_css("a", text: 'My Project' )
      end
    end

    context 'when user clicks a project link' do
      before(:each) {
        click_link 'My Project' 
      }

      it 'should select that project' do
        expect(subject).to have_link('My Project', href: select_project_path(@project) )
        expect(subject).to have_css("mark a", text: 'My Project' )
      end

      it 'should render the default_workspace_path' do
        expect(subject).to have_content "OTUs"
      end
    end

    context 'when user clicks logout' do
      before(:each) {
        click_link 'Sign out'
      }

      it 'should unselect the project when logged back in' do
        sign_in_user
        visit root_path
        expect(subject).to have_no_css("mark a", text: 'My Project' )
        expect(subject).to have_css("a", text: 'My Project' )
      end
    end

  end

  describe 'GET /projects' do
    context 'without admin login' do 
      before { 
        sign_in_user
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
        sign_in_user
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
        sign_in_user
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

    describe '  # POST /projects' do
      context 'logged in users is not a superuser' do 
        before { 
          sign_in_user
          visit projects_path 
        }
        it 'should redirect to hub and present a notice'
      end

      context 'logged in user is a superuser' do
        before {
          sign_in_administrator
          visit projects_path 
        }
        it 'should create the project and redirect to projects/index with a notice'
      end
    end

  end

  describe 'GET /projects/list' do
    before do
      sign_in_user
      $user_id = 1
      # this is so that there are more than one page of projects
      30.times { FactoryGirl.create(:valid_project) }
      visit '/projects/list'
    end

    specify 'that it renders without error' do
      expect(page).to have_content 'Listing Projects'
    end

  end

  describe 'GET /projects/n' do
    before {
      sign_in_user
      $user_id = 1
      3.times { FactoryGirl.create(:valid_project) }
      all_projects = Project.all.map(&:id)
      # there *may* be a better way to do this, but this version *does* work
      visit "/projects/#{all_projects[1]}"
    }

    specify 'there is a \'previous\' link' do
      expect(page).to have_link('Previous')
    end

    specify 'there is a \'next\' link' do
      expect(page).to have_link('Next')
    end

  end

end

