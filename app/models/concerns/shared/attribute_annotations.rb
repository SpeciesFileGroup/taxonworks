# Shared code for polymorphics that reference specific attributes
#
module Shared::AttributeAnnotations
  extend ActiveSupport::Concern

  included do
    with_options if: '!self.send(self.class.annotated_attribute_column).blank?' do |v|
      v.validate :attribute_to_annotate_is_valid_for_object
      v.validate :annotated_value_is_not_identical_to_attribute
    end
  end

  module ClassMethods
  end

  # @return [String]
  def annotated_column
    self.send(self.class.annotated_attribute_column)
  end

  def annotation_value
    self.send(self.class.annotation_value_column)   
  end

  def original_value
    annotated_object.send(annotated_column) if annotated_object.respond_to?(annotated_column)
  end
  
  protected

  # Tests presence of original value AND legality of attribute being annotated
  def attribute_to_annotate_is_valid_for_object
    if !ApplicationEnumeration.annotatable_attributes(annotated_object).include?(annotated_column.to_sym)
      errors.add(self.class.annotated_attribute_column, "#{annotated_column} is not annotatable, it may be empty or non-annotatable") 
    end
  end

  def annotated_value_is_not_identical_to_attribute
    errors.add(self.class.annotated_attribute_column, 'contains annotation identical to existing attribute') if annotation_value == original_value
  end

end
