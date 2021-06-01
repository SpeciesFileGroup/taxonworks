=begin
Shared code for extending data classes with an OriginRelationship

  How to use this concern:
    1) In BOTH related models, Include this concern (`include Shared::OriginRelationship`)
    2) In the "old" model call `is_origin_for` with valid class names, as strings, e.g.:
       `is_origin_for 'CollectionObject', 'CollectionObject::BiologicalCollectionObject'`
    3) In the "old" model call `originates_from` if required.
    4) Repeat assertions in the "new" model.

    5) `has_many :derived_<foo> associations are created for each `is_origin_for()`
    6) `has_many :origin_<foo> associtations are created for each `originates_from()`

    !! You must redundantly provide STI subclasses and parent classes if you want to allow both.  Providing
       a superclass does *not* provide the subclasses.

=end
module Shared::OriginRelationship
  extend ActiveSupport::Concern

  included do
    related_class = self.name

    attr_accessor :origin

    # These are technically only necessary on the new side, but are OK to spam on the old side (some of which need it)
    has_many :origin_relationships, as: :old_object, validate: true, dependent: :destroy
    has_many :related_origin_relationships, class_name: 'OriginRelationship', as: :new_object, validate: true, dependent: :destroy

    accepts_nested_attributes_for :origin_relationships, reject_if: :reject_origin_relationships

    before_validation :set_origin, if: -> {origin.present?}
  end

  def set_origin
    [origin].flatten.each do |object|
      related_origin_relationships.build(old_object: object)
    end
  end

  module ClassMethods
    def is_origin_for(*args)
      if args.length == 0
        raise ArgumentError.new('is_origin_for must have an array full of valid target tables supplied!')
      end

      # @return [Array of Strings]
      #   valid new_object Classes
      define_method :valid_new_object_classes do
        args
      end

      # @return [Array of Strings]
      #   valid new_object Classes
      define_singleton_method :valid_new_object_classes do
        args
      end

      args.each do |a|
        relationship = 'derived_' + a.demodulize.tableize
        has_many relationship.to_sym, source_type: a, through: :origin_relationships, source: :new_object
      end
    end

    def originates_from(*args)
      if args.length == 0
        raise ArgumentError.new('is_origin_for must have an array full of valid target tables supplied!')
      end

      # @return [Array of Strings]
      #   valid new_object Classes
      define_method :valid_old_object_classes do
        args
      end

      # @return [Array of Strings]
      #   valid new_object Classes
      define_singleton_method :valid_old_object_classes do
        args
      end

      args.each do |a|
        relationship = 'origin_' + a.demodulize.tableize
        has_many relationship.to_sym, source_type: a, through: :related_origin_relationships, source: :old_object
      end
    end
  end

  # @return [Objects]
  #   an array of instances, the source of this object
  def old_objects
    related_origin_relationships.collect{|a| a.old_object}
  end

  # @return [Objects]
  #   an array of instances
  def new_objects
    origin_relationships.collect{|a| a.new_object}
  end

  private

  def reject_origin_relationships(attributes)
    o = attributes['new_object']
    if !defined? valid_new_object_classes
      raise NoMethodError.new("#{self.class.name} missing module 'Shared::OriginRelationship' or \"is_origin_for()\" is not being called")
    end

    o.blank? || !valid_new_object_classes.include?(o.class.name)
  end
end
