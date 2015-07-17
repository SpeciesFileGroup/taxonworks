class Role::SourceRole < Role
  include Housekeeping::Users
  include Shared::SharedAcrossProjects

  validates :project_id, absence: true
  after_save :update_source_cached

  def update_source_cached
    self.role_object.save
  end
end
