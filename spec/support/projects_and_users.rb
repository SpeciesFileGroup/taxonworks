# In general you should avoid referencing Current.project_id and Current.user_id globals in tests.
# * They are "on" in model specs via their accessors `user_id` and `project_id`
# * They must never be set in feature specs 
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
    FactoryBot.create(:valid_user, id: 1, self_created: true)
    Current.user_id = 1

    FactoryBot.create(:valid_project, id: 1, without_root_taxon_name: true)
    Current.project_id = 1
    FactoryBot.create(:project_member, user_id: 1, project_id: 1)

    # TODO: Not sure why this is required, perhaps Spring related?! 
    ApplicationRecord.connection.tables.each { |t| ApplicationRecord.connection.reset_pk_sequence!(t) }
  end
end
