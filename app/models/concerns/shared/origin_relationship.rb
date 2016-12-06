=begin
Shared code for extending data classes with an OriginRelationship

  Instructions on how to use this concern:
    1) Include this concern in the table that can have origin relationship target tables
    2) Call "is_origin_for" with valid target tables
      ex is_origin_for :collection_objects, collecting_events etc

=end
module Shared::OriginRelationship
  extend ActiveSupport::Concern

  included do
    has_many :origin_relationships, as: :old_object, validate: true, dependent: :destroy
    accepts_nested_attributes_for :origin_relationships, reject_if: :reject_origin_relationships
  end

  module ClassMethods
    def is_origin_for(*args)
      if args.length == 0
        raise ArgumentError.new("is_origin_for must have an array full of valid target tables supplied!")
      end
      
      # Returns the valid target tables in symbol form
      define_method :valid_origin_target_tables do
        args
      end

      # Returns the valid target tables in class form
      define_singleton_method :valid_origin_target_classes do
        args.collect{ |table_symbol| table_symbol.to_s.classify.constantize }
      end
    end
  end

  private

  def reject_origin_relationships(attributes)
    if !defined? valid_origin_target_tables
      raise NoMethodError.new('"is_origin_for" must be called with valid target tables in the class including the "OriginRelationship" module!')
    end

    attributes['new_object'].blank? || !valid_origin_target_tables.include?(attributes['new_object'].class.table_name.to_sym)
  end
end
