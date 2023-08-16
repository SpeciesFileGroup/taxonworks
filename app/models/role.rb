# A Role relates a Person or an Organization to other data. Both People and Organizations are "data" in TaxonWorks.
# Every Role can reference a Person, a few can reference an Organization.
#
# Roles are the only place where person_id and organization_id must be referenced.

# Had we started from scratch we might have implemented a polymorphic `role_agent`,
# though we reference people *far* more often than organziations, so it would
# have felt klunky to always de-reference to role_agent.
#
# @!attribute person_id
#   @return [Integer]
#    The ID of the Person in the role.
#
# @!attribute organization_id
#   @return [Integer]
#    The ID of the Organization in the role.
#
# @!attribute type
#   @return [String]
#    The type (subclass) of the role, e.g. TaxonDeterminer.
#
# @!attribute role_object_id
#   @return [Integer]
#     The id of the object the role is bound to.
#
# @!attribute role_object_type
#   @return [String]
#     THe class of the object the role is bound to.
#
# @!attribute position
#   @return [Integer]
#     Sort order.
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class Role < ApplicationRecord
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::PolymorphicAnnotator # must be before Shared::IsData (for now)
  include Shared::IsData

  polymorphic_annotates(:role_object, presence_validate: false)
  acts_as_list scope: [:type, :role_object_type, :role_object_id]

  after_save :update_cached

  belongs_to :organization, inverse_of: :roles
  belongs_to :person, inverse_of: :roles

  # Must come after belongs_to associations
  # !! This is only code isolation, not a shared library, probably should be removed
  include Roles::Person

  validates :person, presence: true, unless: Proc.new { organization.present? }
  validates :organization, presence: true, unless: Proc.new { person.present? }
  validates_presence_of :type
  validate :only_one_agent, :agent_is_legal #, :agent_present

  # Overrode in Roles::Organization
  def organization_allowed?
    false
  end

  def agent_type
    if person
      :person
    elsif organization
      :organization
    else
      nil
    end
  end

  protected

  def agent_present
    if !person.present? && !organization.present?
      errors.add(:base, 'missing an agent (person or organization)')
    end
  end

  def agent_is_legal
    if organization.present?
      errors.add(:organization_id, 'is not permitted for this role type') unless organization_allowed?
    end
  end

  # TODO: redundant?
  def only_one_agent
    if person && organization
      errors.add(:person_id, 'organization is also selected')
      errors.add(:organization_id, 'organization is also selected')
    end
  end

  def update_cached
    if role_object.respond_to?(:set_cached, true)
      return true if role_object.respond_to?(:no_cached, true) && role_object.no_cached == true
      role_object.send(:set_cached)
    end
  end

  def is_last_role?
    role_object.roles.count == 0
  end
end

# This list can be reconsidered, but for now:
#
# Person only roles

require_dependency 'taxon_name_author'
require_dependency 'source_source'
require_dependency 'source_author'
require_dependency 'source_editor'
require_dependency 'collector'
require_dependency 'georeferencer'
require_dependency 'determiner'
require_dependency 'loan_recipient'
require_dependency 'loan_supervisor'

# Records below have not been hooked to Person activity years

require_dependency 'accession_provider'
require_dependency 'deaccession_recipient'
require_dependency 'verifier'
require_dependency 'attribution_creator'
require_dependency 'attribution_editor'

# Person OR Organization roles

require_dependency 'attribution_copyright_holder'
require_dependency 'attribution_owner'
