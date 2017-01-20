# See spec/support/projects_and_users for project/user setup for testing framework
module Features
  module AuthenticationHelpers

    def sign_in_with(email, password)
      visit signin_path
      fill_in 'session_email', with: email, wait: 8, id: 'session_email'
      fill_in 'session_password', with: password, wait: 8, id: 'session_password'
      click_button 'sign_in'
      find_link('sign_out')  # TODO: check for Capybara bug fix down the road?
    end

    def select_a_project(project)
      visit select_project_path(project)
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

    def user_project_attributes(user, project)
      {creator: user, updater: user, project: project}
    end

    protected

    def spin_up_project_and_users
      @password = 'abcD123!'
      @user = User.create!(name: 'Pat User', email: 'user@example.com', password: @password, password_confirmation: @password, self_created: true)
      @project_administrator = User.create!(name: 'Pat Project Administrator', email: 'project_administrator@example.com', password: @password, password_confirmation: @password, self_created: true)
      @administrator = User.create!(name: 'Pat the Administrator', email: 'administrator@example.com', password: @password, password_confirmation: @password, is_administrator: true, self_created: true)

      @project = Project.create!(name: 'My Project', creator: @administrator, updater: @administrator, without_root_taxon_name: true)
      @project.project_members.create!(creator: @administrator, updater: @administrator, user: @project_administrator, is_project_administrator: true)
      @project.project_members.create!(creator: @administrator, updater: @administrator, user: @user)
    end
  end
end
