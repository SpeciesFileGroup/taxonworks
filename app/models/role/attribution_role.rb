# A AttributionRole is data within a project.
#
class Role::AttributionRole < Role
  self.abstract_class = true

  include Housekeeping

  before_validation :set_project_if_possible # facilitates << additions

  validates :project_id, presence: true

  protected

  # TODO: this doesn't do what we think it does
  def set_project_if_possible
    self.project = self.role_object.project if self.role_object && self.project.nil?
  end

end
