# A ProjectRole is data within a project.
# @todo Refactor after Housekeeping / FactoryGirl issues resolved (nested set!!)
#
class Role::ProjectRole < Role
  include Housekeeping

  before_validation :set_project_if_possible # facilitates << additions

  validates :project_id, presence: true

  protected

  def set_project_if_possible
    self.project = self.role_object.project if self.role_object && self.project.nil?
  end

end
