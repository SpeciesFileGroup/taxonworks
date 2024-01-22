require "sti_preload"

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
#
class Role < ApplicationRecord

  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::PolymorphicAnnotator # must be before Shared::IsData (for now)
  include Shared::IsData

  # include StiPreload

  polymorphic_annotates(:role_object, presence_validate: false)
  acts_as_list scope: [:type, :role_object_type, :role_object_id]

  # !! Has to be after after_save to not interfer with initial calls
  # !! TODO: revist
  after_commit :set_cached

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
    if person_id
      :person
    elsif organization_id
      :organization
    else
      nil
    end
  end

  def agent
    return person if person_id
    organization
  end

  protected

  def agent_present
    if person.blank? && organization.blank?
      errors.add(:base, 'missing an agent (person or organization)')
    end
  end

  # TODO: redundant?
  def only_one_agent
    if person && organization
      errors.add(:person_id, 'organization is also selected')
      errors.add(:organization_id, 'person is also selected')
    end
  end

  def agent_is_legal
    if organization.present?
      errors.add(:organization_id, 'is not permitted for this role type') unless organization_allowed?
    end
  end

  def is_last_role?
    role_object.roles.count == 0
  end

  #
  # Cache related methods
  #

  # Optionally defined in subclasses to limit
  # which cached (sub) methods should be called
  #   base_class_name: [:method, :method, :method]
  def cached_triggers
    {}
  end

  # @return boolean
  #   true in roles that should have no impact
  #   in any cached value setting.  If false then `set_cached`
  #   will be called unless cached_triggers.presence
  def do_not_set_cached
    false
  end

  def set_cached
    set_role_object_cached
  end

  def set_role_object_cached
    becomes(type.constantize).cached_trigger_methods(role_object).each do |m|
      role_object.send(m) unless role_object.destroyed?
    end
  end

  def cached_trigger_methods(object)
    k = object.class.base_class.name.to_sym
    if cached_triggers[k]
      cached_triggers[k]
    elsif
      object.respond_to?(:set_cached)
      if do_not_set_cached
        return []
      elsif role_object.respond_to?(:no_cached) && role_object.no_cached
        return []
      else
        return [:set_cached]
      end
    else
      []
    end
  end

end

# # This list can be reconsidered, but for now:
# #
# # Person only roles

# require_dependency 'taxon_name_author'
# require_dependency 'source_source'
# require_dependency 'source_author'
# require_dependency 'source_editor'
# require_dependency 'collector'
# require_dependency 'georeferencer'
# require_dependency 'loan_recipient'
# require_dependency 'loan_supervisor'

# # Records below have not been hooked to Person activity years

# require_dependency 'accession_provider'
# require_dependency 'deaccession_recipient'
# require_dependency 'verifier'

# # TODO: these are being used in Attribution, or not?
# require_dependency 'attribution_creator'
# require_dependency 'attribution_editor'

# # Person OR Organization roles
# require_dependency 'attribution_copyright_holder'
# require_dependency 'attribution_owner'
# require_dependency 'determiner'
