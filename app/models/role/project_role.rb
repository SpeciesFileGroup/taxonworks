class Role::ProjectRole < Role
  include Housekeeping

  
  # TODO: Refactor after Housekeeping / FactoryGirl issues resolveds
  before_validation :set_project_if_possible # facilitates << additions

  protected
  def set_project_if_possible
    self.project = self.role_object.project if self.role_object && self.project.nil?
  end

end
