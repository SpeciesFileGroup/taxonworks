# The role that is related to a source (e.g. Editor, Author) 
#
class Role::SourceRole < Role
  self.abstract_class = true

  include Housekeeping::Users
  include Shared::SharedAcrossProjects

  validates :project_id, absence: true
  after_save :update_source_cached

  def update_source_cached
    self.role_object.save
  end
end
