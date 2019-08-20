module Queries
  module Depiction 

    # !! does not inherit from Queries::Query
    class Filter

      include Concerns::Polymorphic
      polymorphic_klass(::Depiction)

      attr_accessor :depiction_object_type, :depiction_object_id 
      attr_accessor :depiction_object_ids
      attr_accessor :depiction_object_types

      attr_accessor :sqed_depiction

      # TODO -> attribute does nothing yet
      # Probably turn it into component parts
      attr_accessor :object_global_id

      # @params params [ActionController::Parameters]
      def initialize(params)
        @query_string = params[:query_string]

        @depiction_object_type = params[:depiction_object_type] 
        @depiction_object_id = params[:depiction_object_id] 

        @depiction_object_ids = params[:depiction_object_ids] || []
        @depiction_object_types = params[:depiction_object_types] || []

        @sqed_depiction = params[:sqed_depiction]&.downcase == 'true' ? true : false

        self.object_global_id = params[:object_global_id]

        set_polymorphic_ids(params)
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          # Queries::Annotator.annotator_params(options, ::Identifier),
          matching_depiction_attribute(:depiction_object_type),
          matching_depiction_attribute(:depiction_object_id),
          matching_depiction_object_types,
          matching_depiction_object_ids,
          matching_polymorphic_ids,
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def merge_clauses
        # from the simple filter
        clauses = [depiction_facet]
        clauses.compact!
        # from the complex query
        # clauses = applied_scopes(clauses).compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.merge(b)
        end
        a
      end

      def depiction_facet
        return nil unless sqed_depiction
        ::Depiction.joins(:sqed_depiction)
      end

      # @return [Arel::Node, nil]
      def matching_depiction_object_ids
        depiction_object_ids.empty? ? nil : table[:depiction_object_id].eq_any(depiction_object_ids)
      end

      # @return [Arel::Node, nil]
      def matching_depiction_object_types
        depiction_object_types.empty? ? nil : table[:depiction_object_type].eq_any(depiction_object_types)
      end

      # @return [Arel::Node, nil]
      def matching_depiction_attribute(attribute)
        v = send(attribute)
        v.blank? ? nil : table[attribute].eq(v)
      end

      # @return [ActiveRecord::Relation]
      def all
        a = and_clauses
        b = merge_clauses

        # q = nil
        if a && b
          q = b.where(a)
        elsif a
          q = ::Depiction.where(a)
        elsif b
          q = b
        else
          q = ::Depiction.all
        end
      end



      # @return [Arel::Table]
      def table
        ::Depiction.arel_table
      end

    end
  end
end
