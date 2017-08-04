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
class OriginRelationship < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData

  acts_as_list scope: [:project_id, :old_object_id, :old_object_type]

  belongs_to :old_object, polymorphic: true 
  belongs_to :new_object, polymorphic: true 

  # Don't validate presence of old_object or new_object
  # so that nested attributes can work in such a way that
  # old_object and new_object don't have to be saved first
  validate :valid_source_target_pairs

  def valid_source_target_pairs
    if old_object_type.nil? || new_object_type.nil?
      errors.add(:old_object, "can't be nil!") if old_object_type.nil?
      errors.add(:new_object, "can't be nil!") if new_object_type.nil?
      return
    end

    old_object_type_class = old_object_type.constantize

    if !old_object_type_class.respond_to?(:valid_new_object_classes)
      errors.add(:old_object, "#{old_object_type} is not a valid origin relationship old object")
    elsif !old_object_type_class.valid_new_object_classes.include?(new_object_type)
      errors.add(:new_object, "#{new_object_type} is not a valid origin relationship new object for old object #{old_object_type}")
    end
  end

end
