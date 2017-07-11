# An OriginRelationship asserts that one object is derived_from another.
class OriginRelationship < ApplicationRecord
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
