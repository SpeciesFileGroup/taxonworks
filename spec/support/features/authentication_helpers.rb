# See spec/support/projects_and_users for project/user setup for testing framework
module Features
  module AuthenticationHelpers

    def sign_up_with(email, password, password_confirmation)
      visit signup_path
      fill_in 'Email',                 with: email
      fill_in 'Password',              with: password
      fill_in 'Password confirmation', with: password_confirmation
      click_button 'Create account'
    end

    def sign_in_with(email, password)
      visit signin_path
      fill_in 'Email',    with: email
      fill_in 'Password', with: password
      click_button 'Sign in'
    end

    def select_a_project(project)
      visit select_project_path(project) 
    end

    # DEPRECATED
    # See the valid_user factory.
    def sign_in_valid_user
      @existing_user = User.find(1)  
      sign_in_with(@existing_user.email, TEST_USER_PASSWORD) 
    end
  
    # DEPRECATED
    def sign_in_valid_user_and_select_project
      sign_in_valid_user
      select_a_project(Project.find(1))
    end

    def sign_in_project_administrator_and_select_project
      sign_in_project_administrator
      select_a_project(@project)
    end

    def sign_in_user_and_select_project
      sign_in_user
      select_a_project(@project)
    end

    def sign_in_administrator_and_select_project
      sign_in_administrator
      select_a_project(@project)
    end

    def sign_in_user
      spin_up_project_and_users
      sign_in_with(@user.email, @password)
    end

    def sign_in_administrator
      spin_up_project_and_users
      sign_in_with(@administrator.email, @password)
    end

    def sign_in_project_administrator
      spin_up_project_and_users
      sign_in_with(@project_administrator.email, @password)
    end

    protected

    def spin_up_project_and_users
      @password = 'abcD123!'
      @user = User.create(name: 'Pat User', email: 'user@test.com', password: @password , password_confirmation: @password)
      @project_administrator = User.create(name: 'Pat Proj Admin', email: 'project_administrator@test.com', password: @password, password_confirmation: @password)
      @administrator = User.create(name: 'Pat the Admin', email: 'administrator@test.com', password: @password, password_confirmation: @password, is_administrator: true)
      @project = Project.create(name: 'My Project', creator: @administrator, updater: @administrator)
      @project.project_members.build(creator: @administrator, updater: @administrator, user: @project_administrator, is_project_administrator: true)
      @project.project_members.build(creator: @administrator, updater: @administrator, user: @user) # build
      @project.save!
    end
  end
end
