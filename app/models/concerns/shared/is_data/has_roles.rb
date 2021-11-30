# Shared code Roles support, includes Verifier support at present.
#
module Shared::IsData::HasRoles

  extend ActiveSupport::Concern
  included do
    
    has_many :roles, -> { order(:position) }, as: :role_object, dependent: :destroy
    # define has_many :people, through: <role_subclass>

    accepts_nested_attributes_for :roles, allow_destroy: true, reject_if: :all_blank
  end

  def has_roles?
    roles.size > 0
  end

end
