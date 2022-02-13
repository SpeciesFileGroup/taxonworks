# Helper methods for polymorphic annotators.
# Extends annotators so that global_id strings can be used as attributes referencing the polymorphic object.
#
# To implement:
#     include Shared::PolymorphicAnnotator
#     polymorphic_annotates('belongs_to_name', 'foreign_key')
#
# The foreign_key argument is optional, and only necessary when it can't be derived from the belongs_to_name.
#
# Implementing concerns, for example Shared::Taggable, should push
# foreign keys, like:
#
#  Tag.related_foreign_keys.push self.name.foreign_key
#
#
# TODO: sometime way down the line revisit this
# !! This should be fine when inverse_of: attributes are added !!
# Please DO NOT include the following:
#   validates :<foo>_object, presence: true
#   validates_presence_of :<foo>_object_type, :<foo>_object_id
#
module Shared::PolymorphicAnnotator
  extend ActiveSupport::Concern

  class_methods do
    # @return [String]
    #    the polymorphic _id column
    def annotator_id
      reflections[annotator_reflection].foreign_key.to_s
    end

    # @return [String]
    #    the polymorphic _type column
    def annotator_type
      reflections[annotator_reflection].foreign_type
    end

    # @return [Array]
    #   of Strings, those foreign keys this object annotates
    def related_foreign_keys
      @related_foreign_keys
    end

    def related_foreign_keys=(value)
      @related_foreign_keys.push value
    end
  end

  included do
    # Concern implementation macro
    def self.polymorphic_annotates(polymorphic_belongs, foreign_key = nil) # , inverse_of = nil)
      # inverse_of ||= self.table_name.to_sym
      belongs_to polymorphic_belongs.to_sym, polymorphic: true, foreign_key: (foreign_key.nil? ? (polymorphic_belongs.to_s + '_id').to_s : polymorphic_belongs.to_s) # TODO: add for validation , inverse_of: inverse_of # polymorphic_belongs.to_sym
      alias_attribute :annotated_object, polymorphic_belongs.to_sym

      define_singleton_method(:annotator_reflection){polymorphic_belongs.to_s}
    end

    # @return [Array]
    #   the foreign keys from taggable classes
    @related_foreign_keys = []

    attr_accessor :annotated_global_entity

    # @return [String]
    #   the global_id of the annotated object
    def annotated_global_entity
      annotated_object.to_global_id if annotated_object.present?
    end

    # @return [True]
    #    set the object when passed a global_id String
    def annotated_global_entity=(entity)
      o = GlobalID::Locator.locate entity

      write_attribute(self.class.annotator_id, o.id)
      write_attribute(self.class.annotator_type, o.class.base_class)
      true
    end
  end

end
