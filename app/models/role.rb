# A Role relates a Person (a Person is data in TaxonWorks) to other data.
#
# @!attribute person_id
#   @return [Integer]
#    The ID of the person in the role.
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

  acts_as_list scope: [:type, :role_object_type, :role_object_id]

  after_save :vet_person
  after_save :update_cached
  after_save :update_person_year_metadata
  after_destroy :check_for_last

  belongs_to :role_object, polymorphic: :true #, validate: true
  belongs_to :person, inverse_of: :roles, validate: true
  accepts_nested_attributes_for :person, reject_if: :all_blank, allow_destroy: true

  # role_object is required but at the database constraint level at present
  # validates :role_object, presence: true
  validates_presence_of :type
  validates :person, presence: true
  validates_uniqueness_of :person_id, scope: [:role_object_id, :role_object_type, :type]

  protected

  def update_cached
    # TODO: optimize, perhaps on set_author_year
    role_object.send(:set_cached) if role_object.respond_to?(:set_cached, true)
  end

  def check_for_last
    if is_last_role? && role_object_type == 'Source'
      add_touch = false
      if type == 'SourceAuthor'
        role_object.update_columns(author: nil, cached_author_string: nil)
        add_touch = true
      end
      if type == 'SourceEditor'
        add_touch = true
        role_object.update_columns(editor: nil)
      end
      role_object.touch
    else
      role_object.send(:set_cached) if role_object.respond_to?(:set_cached, true)
    end
  end

  def is_last_role?
    role_object.roles.count == 0
  end

  # See /app/models/person.rb for a definition of vetted
  def vet_person
    # Check whether there are one or more *other* roles besides this one, 
    # i.e. there are at least *2* for person_id
    if Role.where(person_id: person_id).where.not(id: id).any?
      person.update_column(:type, 'Person::Vetted') 
    end
  end

  def update_person_year_metadata
    if role_object.respond_to?(:year)
      begin
        y = role_object.try(:year)
        y ||= role_object.try(:year_of_publication)

        yas = [y, person.year_active_start].compact.map(&:to_i).min
        yae = [y, person.year_active_end].compact.map(&:to_i).max

        person.update(
          year_active_end: yae,
          year_active_start: yas
        )

      rescue ActiveRecord::RecordInvalid
        # probably a year conflict, allow quietly
      end
    end
  end

end

require_dependency 'taxon_name_author'
require_dependency 'source_source'
require_dependency 'source_author'
require_dependency 'source_editor'
require_dependency 'collector'
require_dependency 'georeferencer'
require_dependency 'determiner'
require_dependency 'type_designator'
require_dependency 'loan_recipient'
require_dependency 'loan_supervisor'
require_dependency 'accession_provider'
require_dependency 'deaccession_recipient'
require_dependency 'attribution_copyright_holder'
require_dependency 'attribution_creator'
require_dependency 'attribution_editor'
require_dependency 'attribution_owner'
