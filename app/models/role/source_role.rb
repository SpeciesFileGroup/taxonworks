class Role::SourceRole < Role
  include Housekeeping::Users

  validates :project_id, absence: true
end
