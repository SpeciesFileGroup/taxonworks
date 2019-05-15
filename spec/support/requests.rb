RSpec.configure do |config|
  config.before(:all, type: :request) do
    ProjectsAndUsers.spin_up_projects_users_and_housekeeping
  end 

  config.after(:all, type: :request) { 
    ProjectsAndUsers.clean_slate
  }
end
