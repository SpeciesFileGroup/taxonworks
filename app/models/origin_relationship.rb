# An OriginRelationship asserts that one object is derived_from another.
class OriginRelationship < ActiveRecord::Base
  include Housekeeping
  
  belongs_to :old_object, polymorphic: true # Source of new object
  belongs_to :new_object, polymorphic: true # Comes from the old object, result

=begin
old_object           new_object
 
field_observation / collection_object

collection_object / collection_object

collection_object / extract

collection_object / part_of (anatomy)

part_of / part_of

part_of / extract

extract / extract

extract / sequence

sequence / sequence
=end

  # Don't validate presence of old_object or new_object
  # so that nested attributes can work in such a way where
  # the old_object and new_object don't have to be saved first
  # validates_presence_of :old_object, :new_object

  validate :valid_source_target_pairs

  def valid_source_target_pairs
    if old_object_type.nil? || new_object_type.nil?
      errors.add(:source, "can't be nil!") if old_object_type.nil?
      errors.add(:target, "can't be nil!") if new_object_type.nil?
      return
    end

    old_object_type_class = old_object_type.constantize

    if !old_object_type_class.respond_to?(:valid_origin_target_classes)
      errors.add(:source, "#{old_object_type} is not a valid origin relationship source!")
    elsif !old_object_type_class.valid_origin_target_classes.include?(new_object_type.constantize)
      errors.add(:target, "#{new_object_type} is not a valid origin relationship target for source #{old_object_type}")
    end
  end
end
