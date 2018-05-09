module Queries
  module DataAttribute 

    # !! does not inherit from base query
    class Filter 

      # General annotator options handling 
      # happens directly on the params as passed
      # through to the controller, keep them
      # together here
      attr_accessor :options

      # Params specific to DataAttribute
      attr_accessor :value, :predicate_id, :import_predicate

      def initialize(params)
        @value = params[:value]
        @predicate_id = params[:predicate_id]
        @import_predicate = params[:import_predicate]
        @options = params 
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          Queries::Annotator.annotator_params(options, ::DataAttribute),
          matching_value,
          matching_import_predicate,
          matching_predicate_id
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [Arel::Node, nil]
      def matching_value
        value.blank? ? nil : table[:value].eq(value) 
      end

      # @return [Arel::Node, nil]
      def matching_import_predicate
        import_predicate.blank? ? nil : table[:import_predicate].eq(import_predicate) 
      end

      # @return [Arel::Node, nil]
      def matching_predicate_id
        predicate_id.blank? ? nil : table[:predicate_id].eq(predicate_id) 
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          ::DataAttribute.where(and_clauses)
        else
          DataAttribute.none
        end
      end

      # @return [Arel::Table]
      def table
        ::DataAttribute.arel_table
      end
    end
  end
end
