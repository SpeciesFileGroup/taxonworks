# A Role relates a Person (a Person is data in TaxonWorks) to other data.
#
# @!attribute person_id
#   @return [Integer]
#   @todo
#
# @!attribute type
#   @return [String]
#   @todo
#
# @!attribute role_object_id
#   @return [Integer]
#   @todo
#
# @!attribute role_object_type
#   @return [String]
#   @todo
#
# @!attribute position
#   @return [Integer]
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class Role < ActiveRecord::Base

  include Housekeeping::Users
  include Shared::IsData

  acts_as_list scope: [:type, :role_object_type, :role_object_id]

  belongs_to :role_object, polymorphic: :true, validate: true
  belongs_to :person, inverse_of: :roles, validate: true
  accepts_nested_attributes_for :person, reject_if: :all_blank, allow_destroy: true

  # Note:
  # - acts_as_list adds :position in a manner that can not be validated with validate_presence_of
  # - role_object is required but at the database constraint level at present
  # validates :role_object, presence: true
  validates_presence_of :type
  validates :person, presence: true

  validates_uniqueness_of :person_id, scope: [:role_object_id, :role_object_type, :type]

  after_save :vet_person

  protected

  def vet_person
    if Role.where(person_id: self.person_id).count > 1
      p = Person.find(person_id)
      p.update(type: 'Person::Vetted')
    end
  end

end

require_dependency 'source_source'
require_dependency 'source_author'
require_dependency 'source_editor'
require_dependency 'determiner'
require_dependency 'collector'
require_dependency 'taxon_name_author'
