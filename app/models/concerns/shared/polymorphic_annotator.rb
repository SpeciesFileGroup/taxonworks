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

    # @return Array of class names can be cited
    def related_klasses
      related_foreign_keys.sort{|a,b| a.to_s <=> b.to_s}.collect{|k| k.to_s.gsub('_id', '').camelize }
    end
  end

  included do

    attr_accessor :annotated_object

    # Concern implementation macro
    #
    # @param foreign_key [String, nil]
    #   If the FK is not inferable in a Rails convention (adding `_id`) provide it here
    #
    # @param inverse_of [Symbol, nil]
    #   If the inverse_of is not the class name underscored and pluralized provide it here
    #
    # @param presence_validate [Boolean, nil]
    #   When true then add validation checks on annotated_object
    #
    def self.polymorphic_annotates(polymorphic_belongs, foreign_key: nil, inverse_of: nil, presence_validate: true)

      inverse_of ||= self.name.underscore.pluralize

      belongs_to(polymorphic_belongs.to_sym, polymorphic: true, foreign_key: (foreign_key.nil? ? (polymorphic_belongs.to_s + '_id').to_s : polymorphic_belongs.to_s),
        inverse_of:)

      alias_method :annotated_object, polymorphic_belongs.to_sym
      alias_method :annotated_object=, (polymorphic_belongs.to_s + '=').to_sym

      define_singleton_method(:annotator_reflection){polymorphic_belongs.to_s}

      # Label does not require object to be present
      if presence_validate
        validates_presence_of polymorphic_belongs.to_sym #, presence: true
        validates_associated polymorphic_belongs.to_sym

        validate :annotated_object_is_persisted?, unless: Proc.new { annotator_batch_mode }
      end
    end

    # @return [Array]
    #   the foreign keys from taggable classes
    @related_foreign_keys = []

    attr_accessor :annotated_global_entity

    # @param Boolean, nil
    #   true - skip DB check of annotated_object presence
    #   false, nil - ignored
    #
    # Tested in /app/models/identifier_spec.rb
    attr_accessor :annotator_batch_mode

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

  private

  # Since we can't FK on polymorphics we use this
  # to test that the annotated_object actually is
  # present in the database.
  def annotated_object_is_persisted?
    if annotated_object
      # We can't test `persisted?` since destroyed in-memory objects will
      # be interfered with.
      if !annotated_object.id.nil?
        begin
          # !! Do not use annotate_object.reload as it resets
          # the object in memory. !!
          annotated_object.class.find(annotated_object.id)
        rescue ActiveRecord::RecordNotFound
          errors.add(:base, 'annotated object no longer exists')
        end
      end
    end
  end

end
