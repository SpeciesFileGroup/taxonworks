# An OriginRelationship asserts that one object is derived_from another.
#
# The old object is the source_of or origin_of the new object.
# The new object originates_from the old_object.
#
# Currently these combinations are planned (* not implemented):
#
# old_object / new_object
#
# * field_observation / collection_object
# collection_object / collection_object
# collection_object / extract
# * collection_object / part_of (anatomy)
# * part_of / part_of
# * part_of / extract
# extract / extract
# extract / sequence
# sequence / sequence
#
# @!attribute old_object_id
#   @return [Integer]
#     id of the old (original) object
#
# @!attribute old_object_type
#   @return [Integer]
#     type of the old (original) object
#
# @!attribute new_object_id
#   @return [Integer]
#     id of the new (original) object
#
# @!attribute new_object_type
#   @return [Integer]
#     type of the new (original) object
#
# @!attribute position
#   @return [Integer]
#     order relative to old object
#
# @!attribute project_id
#   @return [Integer]
#     the project ID
#
class OriginRelationship < ApplicationRecord
  include Housekeeping
  include Shared::IsData
  include Shared::PolymorphicAnnotator

  polymorphic_annotates('old_object')
  polymorphic_annotates('new_object')

  acts_as_list scope: [:project_id, :old_object_id, :old_object_type]

  belongs_to :old_object, polymorphic: true, inverse_of: :origin_relationships
  belongs_to :new_object, polymorphic: true, inverse_of: :related_origin_relationships

  # The two validations, and the inclusion of the Shared::OriginRelationship code
  # ensure that new/old objects are indeed ones that are allowed (otherwise we will get Raises, which means the UI is messed up)
  validates_presence_of :new_object
  validates_presence_of :old_object

  validate :pairing_is_allowed, unless: -> {!errors.empty?}

  private

  def pairing_is_allowed
    errors.add(:old_object, "#{old_object_type} is not a valid origin relationship old object") if !new_object.valid_old_object_classes.include?(old_object.class.name)
    errors.add(:new_object, "#{new_object_type} is not a valid origin relationship old object") if !old_object.valid_new_object_classes.include?(new_object.class.name)
  end

end
