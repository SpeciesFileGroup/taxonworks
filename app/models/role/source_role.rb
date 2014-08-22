class Role::SourceRole < Role
  include Housekeeping::Users
  include Shared::SharedAcrossProjects

  validates :project_id, absence: true
end
