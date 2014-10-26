RSpec.configure do |config|
  config.before(:example) do
    ProjectsAndUsers.spin_up_projects_users_and_housekeeping
  end 

#  config.after(:all, type: :helper) { 
#    ProjectsAndUsers.clean_slate
#  }
end
