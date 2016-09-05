=begin
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
      define_method :get_valid_origin_relationship_target_tables do
        if args.length == 0
          raise ArgumentError.new("is_origin_for must have valid target tables supplied!")
        end

        args
      end
    end
  end

  private

  def reject_origin_relationships(attributes)
    if !defined? get_valid_origin_relationship_target_tables
      raise NoMethodError.new('"is_origin_for" must be called with valid target tables in the class including the "OriginRelationship" module!')
    end

    attributes['new_object'].blank? || !get_valid_origin_relationship_target_tables.include?(attributes['new_object'].class.table_name.to_sym)
  end
end