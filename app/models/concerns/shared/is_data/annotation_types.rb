# What kinds of annotation a class can carry. Introspection only, safe to
# include in non-Data classes, where every check is false.
#
module Shared::IsData::AnnotationTypes

  extend ActiveSupport::Concern

  module ClassMethods

    # Determines whether the class can be annotated
    # in one of the following ways
    ::ANNOTATION_TYPES.each do |t|
      define_method("has_#{t}?") do
        k = "Shared::#{t.to_s.singularize.classify.pluralize}".safe_constantize
        self < k ? true : false
      end
    end

    def available_annotation_types
      ::ANNOTATION_TYPES.collect do |a|
        self.send("has_#{a}?") ? a.to_s.classify : nil
      end.compact
    end
  end

  # Determines whether the instance can be annotated
  # in one of the following ways
  ::ANNOTATION_TYPES.each do |t|
    define_method("has_#{t}?") do
      k = "Shared::#{t.to_s.singularize.classify.pluralize}".safe_constantize
      self.class < k ? true : false
    end
  end

  def available_annotation_types
    ::ANNOTATION_TYPES.select do |a|
      self.send("has_#{a}?")
    end
  end

end
