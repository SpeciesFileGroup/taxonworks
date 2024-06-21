# In general you should avoid referencing Current.project_id and Current.user_id globals in tests.
# * They are "on" in model specs via their accessors `user_id` and `project_id`
# * They must never be set in feature specs
module ProjectsAndUsers

  def self.clean_slate
    ProjectMember.delete_all
    Project.delete_all
    User.delete_all

    # TODO: should not be needed anymore
    # Current.user_id = nil
    # Current.project_id = nil
  end

  # This is used before all tests of type :model, :controller, :helper
  # id 1 matters!!
  def self.spin_up_projects_users_and_housekeeping
    u = FactoryBot.create(:valid_user, id: 1, self_created: true)
    FactoryBot.create(:valid_project, id: 1, without_root_taxon_name: true, by: u)
    FactoryBot.create(:project_member, user_id: 1, project_id: 1, by: u)

    # TODO: Not sure why this is required, perhaps Spring related?!
    ApplicationRecord.connection.tables.each { |t| ApplicationRecord.connection.reset_pk_sequence!(t) }
  end
end
