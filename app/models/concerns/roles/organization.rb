module Roles::Organization
  extend ActiveSupport::Concern

  included do
    with_options if: :organization_role? do |o|
      o.validates_uniqueness_of :organization_id, scope: [:role_object_id, :role_object_type, :type], allow_nil: true
      o.validates :organization, presence: true
    end
  end

  class_methods do
  end

  def organization_allowed?
    true
  end

  protected

  def organization_role?
    organization.present? && !person
  end

end

