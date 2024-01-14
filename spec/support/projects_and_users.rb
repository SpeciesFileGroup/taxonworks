# In general you should avoid referencing Current.project_id and Current.user_id globals in tests.
# * They are "on" in Model specs via their accessors are `user_id` and `project_id`
# * !! They must never be set in feature specs. 
require 'user'
module ProjectsAndUsers

  def self.clean_slate 
    ProjectMember.delete_all
    Project.delete_all 
    User.delete_all
    Current.user_id = nil
    Current.project_id = nil
  end

  # This is used before all tests of type :model, :controller, :helper
  def self.spin_up_projects_users_and_housekeeping

    # Order matters
  #User.create!(
  #  name: 'test',
  #  email: 'person1@example.com',
  #  password: Rails.configuration.x.test_user_password,
  #  password_confirmation:  Rails.configuration.x.test_user_password,
  #  self_created: true
  #) 

     FactoryBot.create(:valid_user, id: 1, self_created: true)
    
    Current.user_id = 1

    FactoryBot.create(:valid_project, id: 1, without_root_taxon_name: true)
    Current.project_id = 1
    FactoryBot.create(:project_member, user_id: 1, project_id: 1)

    # TODO: Not sure why this is required, perhaps Spring related?! 
    ApplicationRecord.connection.tables.each { |t| ApplicationRecord.connection.reset_pk_sequence!(t) }
  end
end
