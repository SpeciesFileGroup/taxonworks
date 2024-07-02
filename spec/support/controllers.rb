require_relative 'controller_spec_helper'

RSpec.configure do |config|
  config.include ControllerSpecHelper, type: :controller
  config.before(:all, type: :controller) do
    ProjectsAndUsers.spin_up_projects_users_and_housekeeping
  end

  config.after(:all, type: :controller) {
    ProjectsAndUsers.clean_slate
  }
end
