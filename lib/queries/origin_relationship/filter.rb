module Queries
  module OriginRelationship

    # !! does not inherit from Queries::Query
    class Filter

      include Concerns::Polymorphic
      polymorphic_klass(::OriginRelationship)

      attr_accessor :new_object_global_id
      attr_accessor :old_object_global_id

      # @params params [ActionController::Parameters]
      def initialize(params)
      # @identifier_object_type = params[:identifier_object_type] 
      # @identifier_object_id = params[:identifier_object_id] 

      # # TODO: deprecate, see README.md
      # @identifier_object_ids = params[:identifier_object_ids] || []
      # @identifier_object_types = params[:identifier_object_types] || []

        @new_object_global_id = params[:new_object_global_id]
        @old_object_global_id = params[:old_object_global_id]

        set_polymorphic_ids(params)
        # need 'set annotator params'
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          # Queries::Annotator.annotator_params(options, ::OriginRelationship),
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

      # @return [Arel::Table]
      def table
        ::OriginRelationship.arel_table
      end

    end
  end
end
