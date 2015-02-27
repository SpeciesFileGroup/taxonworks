require 'rails_helper'

describe 'Project Handling', :type => :feature do

  subject { page }

  describe '/' do
    before { 
      sign_in_user
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

      it 'should select that project and reference it in the hub' do
        expect(subject).to have_content "Hub"
        expect(subject).to have_content('My Project') 
      end
    end

    context 'when user clicks logout' do
      before(:each) {
        @previous_user = @user
        @previous_password = @password
        click_link 'Sign out'
      }

      it 'should unselect the project when logged back in' do
        sign_in_with(@previous_user.email, @previous_password)
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

  context 'with some projects created' do
    before {
      sign_in_user
      5.times { factory_girl_create_for_user(:valid_project, @user)   } 
    } 

    describe 'GET /projects/list' do
      before {
        visit list_projects_path}


      specify 'that it renders without error' do
        expect(page).to have_content 'Listing Projects'
      end
    end

    describe 'GET /projects/n' do
      before { visit project_path(Project.first) }
      xspecify 'there is the projects name' do
      end
    end
  end
end
