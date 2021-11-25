module Shared::Verifiers

  extend ActiveSupport::Concern
  included do
    has_many :verifier_roles, class_name: 'Verifier', as: :role_object, dependent: :destroy
    has_many :verifiers, through: :verifier_roles, source: :person, inverse_of: :collecting_events

    accepts_nested_attributes_for :verifier_roles, allow_destroy: true
  end

  def is_verified?
    verifier_roles.any?
  end

end
