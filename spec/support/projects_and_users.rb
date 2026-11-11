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

  # This is used before all tests of type :model, :helper, :controller,
  # :request and :spinup
  # id 1 matters!!
  #
  # Id sequences are not reset between spec files, so specs must not depend
  # on particular ids, or on ids in different tables coinciding.
  def self.spin_up_projects_users_and_housekeeping
    user = FactoryBot.create(:valid_user, id: 1, self_created: true)
    project = FactoryBot.create(:valid_project, id: 1, without_root_taxon_name: true, by: user)
    FactoryBot.create(:project_member, user_id: 1, project_id: 1, by: user)

    # A record created with an explicit id doesn't advance its table's id
    # sequence, so the next record created in that table would collide with
    # it. Reset the sequence of every table given an explicit id above.
    [user, project].each do |record|
      ApplicationRecord.connection.reset_pk_sequence!(record.class.table_name)
    end
  end
end
