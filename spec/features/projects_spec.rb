require 'rails_helper'

describe 'Project Handling', type: :feature do

  subject { page }

  describe 'GET /' do
    before { 
      sign_in_user
    }

    context 'when a user is signed in they see a list of projects (in the hub)' do
      it 'should have a list of project links' do 
        expect(subject).to have_link('My Project', href: select_project_path(@project) )
        expect(subject).to have_css('a', text: 'My Project' )
      end
    end

    context 'when user clicks a project link' do
      before(:each) {
        click_link 'My Project' 
      }

      it 'should select that project and reference it in the hub' do
        expect(subject).to have_content 'Hub'
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
        expect(subject).to have_no_css('mark a', text: 'My Project' )
        expect(subject).to have_css('a', text: 'My Project' )
      end
    end

  end

  describe 'GET /projects' do
    context 'with administrator login' do
      before {
        sign_in_administrator
        visit projects_path 
      }
   
      specify  'there is a List link' do
        expect(page).to have_link('List')
      end

      specify  'there is a New link' do
        expect(page).to have_link('New')
      end
    end

    context 'with project_administrator login' do
      before {
        sign_in_project_administrator
        visit projects_path 
      }

      specify  'there is a List link' do
        expect(page).to have_content('Projects')
        expect(page).to have_link('List')
      end

      specify  'there is NOT a New link' do
        expect(page).to_not have_link('New')
      end
    end

    context 'as user' do
      before {
        sign_in_user
        visit projects_path 
      }

      specify 'it prompts user to sign in as administrator on Dashboard' do
        expect(page).to have_content('Please sign in as a project administrator or administrator.')
        expect(page).to have_content('Dashboard')
      end
    end
  end

  describe 'GET /projects/1' do
    context 'logged in as a project administrator' do 
      before { 
        sign_in_project_administrator_and_select_project
        visit project_path(@project.id) 
      }

      specify 'it should show the project page' do
        expect(page).to have_content('My Project')
        expect(page).to have_content('Project attributes')
      end

      specify 'it should have an Edit link' do
        expect(page).to have_link('Edit')
      end

      specify 'it should have an Add project member link' do
        expect(page).to have_link('Add project member')
      end

      specify 'it should have an Add a new user link' do
        expect(page).to have_link('Add new user')
      end
    end

    context 'logged in as user' do
      before {
        sign_in_user_and_select_project
        visit project_path(@project.id) 
      }
      specify 'not allowed- redirected to dashboard' do
        expect(page).to have_content('Dashboard')
      end
    end
  end
  
  describe 'GET /projects/1/edit' do
    context 'logged in as project administrator' do 
      before { 
        sign_in_project_administrator_and_select_project
        visit edit_project_path(@project) 
      }

      specify 'should render the edit form' do
        expect(page).to have_content('Editing project')
      end
     
      specify 'project can be udpated' do
        fill_in 'Name', with: 'Better project name' 
        click_button 'Update Project'
        expect(page).to have_content('Better project name')
        expect(page).to have_content('Project was successfully updated.')
      end


    end

    context 'with admin, non-member login' do
      before {
        sign_in_administrator
        visit projects_path 
      }
      # it 'should render the edit form'
    end

    context 'with non-superuser project member' do
      before {
        sign_in_administrator
        visit projects_path 
      }
      # it 'should redirect to hub and present a notice'
    end

    describe '  # POST /projects' do
      context 'logged in users is not a superuser' do 
        before { 
          sign_in_user
          visit projects_path 
        }
        # it 'should redirect to hub and present a notice'
      end

      context 'logged in user is a superuser' do
        before {
          sign_in_administrator
          visit projects_path 
        }
        # it 'should create the project and redirect to projects/index with a notice'
      end
    end
  end

  context 'with some projects created' do
    before do
      sign_in_user
      3.times.each_with_index do |t, i|
        Project.create!(name: "p#{i}", creator: @user, updater: @user)
      end
    end 

    describe 'GET /projects/list' do
      before {
        visit list_projects_path}

      specify 'that it renders without error' do
        expect(page).to have_content(/Displaying.*projects/)
      end
    end
  end
end
