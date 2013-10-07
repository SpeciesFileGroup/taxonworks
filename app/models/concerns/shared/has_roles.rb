module Shared::HasRoles

  extend ActiveSupport::Concern
  included do
    has_many :roles, as: :has_roles
  end

  def has_roles?
    self.roles.size > 0
  end

  protected

end
