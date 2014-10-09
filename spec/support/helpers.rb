RSpec.configure do |config|
  config.before(:all, type: :helper) do
    ProjectsAndUsers.spin_up_projects_users_and_housekeeping
  end 

  config.after(:all, type: :helper) { 
    ProjectsAndUsers.clean_slate
  }
end
