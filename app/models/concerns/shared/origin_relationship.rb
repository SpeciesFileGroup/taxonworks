=begin
Shared code for extending data classes with an OriginRelationship

  Instructions on how to use this concern:
    1) In BOTH related models, Include this concern (include Shared::OriginRelationship) 
    2) In the "old" model call "is_origin_for" with valid class names, as strings, e.g.:
       is_origin_for 'CollectionObject', 'CollectionObject::BiologicalCollectionObject'
    3) has_many :derived_<foo> associations are created for each is_origin_for()

      You must redundantly provide STI subclasses and parent classes if you want to allow both.  Providing
      a superclass does *not* provide the subclasses.

=end
module Shared::OriginRelationship
  extend ActiveSupport::Concern

  included do
    related_class = self.name

    # these are technically only necessary on the new side, but are OK to spam on the old side (some of which need it)
    has_many :origin_relationships, as: :old_object, validate: true, dependent: :destroy
    has_many :related_origin_relationships, class_name: 'OriginRelationship', as: :new_object, validate: true, dependent: :destroy

    accepts_nested_attributes_for :origin_relationships, reject_if: :reject_origin_relationships
  end

  module ClassMethods
    def is_origin_for(*args)
      if args.length == 0
        raise ArgumentError.new("is_origin_for must have an array full of valid target tables supplied!")
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
  end

  def old_objects
    related_origin_relationships.collect{|a| a.old_object}
  end

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
