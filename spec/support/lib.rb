RSpec.configure do |config|
  config.before(:all, type: :spinup) do
    ProjectsAndUsers.spin_up_projects_users_and_housekeeping
  end 

  config.after(:all, type: :spinup) { 
    ProjectsAndUsers.clean_slate
  }
end
