# The role that is related to a source (e.g. Editor, Author) 
#
class Role::SourceRole < Role
  self.abstract_class = true

  include Housekeeping::Users
  include Shared::SharedAcrossProjects

  validates :project_id, absence: true

  after_save :update_source_cached

  def update_source_cached
    role_object.send(:set_cached) if role_object.respond_to?(:set_cached, true)
  end

end
