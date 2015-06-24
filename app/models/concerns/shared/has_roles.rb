module Shared::HasRoles

  extend ActiveSupport::Concern
  included do

    has_many :roles, -> {order(:position)}, as: :role_object, dependent: :destroy
  end

  def has_roles?
    self.roles.size > 0
  end

end
