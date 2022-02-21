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
  include Shared::IsData

  include Shared::PolymorphicAnnotator
  polymorphic_annotates(:role_object)

  acts_as_list scope: [:type, :role_object_type, :role_object_id]

  belongs_to :organization, inverse_of: :roles, validate: true
  belongs_to :person, inverse_of: :roles, validate: true
  belongs_to :role_object, polymorphic: :true #, validate: true

  after_save :update_cached

  validates_presence_of :type
  validate :agent_present,
    :only_one_agent,
    :agent_is_legal

  # validates_uniqueness_of :person_id, scope: [:project_id, :role_object_type, :role_object_id]

  # role_object presence is a database constraint level
  # validates :role_object, presence: true

  # Must come after belongs_to associations
  include Roles::Person

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

  def only_one_agent
    if person && organization
      errors.add(:person_id, 'organization is also selected')
      errors.add(:organization_id, 'organization is also selected')
    end
  end

  def update_cached
    # TODO: optimize, perhaps on set_author_year
    role_object.send(:set_cached) if role_object.respond_to?(:set_cached, true)
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
require_dependency 'accession_provider'
require_dependency 'deaccession_recipient'
require_dependency 'verifier'
require_dependency 'attribution_creator'
require_dependency 'attribution_editor'

# Person OR Organization roles

require_dependency 'attribution_copyright_holder'
require_dependency 'attribution_owner'
