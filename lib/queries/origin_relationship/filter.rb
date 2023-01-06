module Queries
  module OriginRelationship
    class Filter < Query::Filter

      include Concerns::Polymorphic
      polymorphic_klass(::OriginRelationship)

      # attr_accessor :object_global_id  from Queries::Concerns::Polymorphic
      # attr_accessor :polymorphic_ids   from Queries::Concerns::Polymorphic

      attr_accessor :new_object_global_id
      attr_accessor :old_object_global_id

      def initialize(params)
        @new_object_global_id = params[:new_object_global_id]
        @old_object_global_id = params[:old_object_global_id]

        set_polymorphic_ids(params)
      end

      def new_object
        if o = GlobalID::Locator.locate(new_object_global_id)
          o
        else
          nil
        end
      end

      def old_object
        if o = GlobalID::Locator.locate(old_object_global_id)
          o
        else
          nil
        end
      end

      def matching_new_object_facet
        return nil if new_object_global_id.nil?
        table[:new_object_type].eq(new_object.class.base_class)
          .and(table[:new_object_id].eq(new_object.id))
      end

      def matching_old_object_facet
        return nil if old_object_global_id.nil?
        table[:old_object_type].eq(old_object.class.base_class)
          .and(table[:old_object_id].eq(old_object.id))
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          matching_new_object_facet,
          matching_old_object_facet,
          matching_polymorphic_ids
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      def merge_clauses
        clauses = [
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.merge(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        a = and_clauses
        b = merge_clauses
        if a && b
          b.where(a).distinct
        elsif a
          ::OriginRelationship.where(a).distinct
        elsif b
          b.distinct
        else
          ::OriginRelationship.all
        end
      end

    end
  end
end
