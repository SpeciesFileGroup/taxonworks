module Queries
  module Confidence 

    # !! does not inherit from base query
    class Filter 

      # General annotator options handling 
      # happens directly on the params as passed
      # through to the controller, keep them
      # together here
      attr_accessor :options

      # Params specific to Confidence 

      # Array, Integer
      attr_accessor :confidence_level_id

      def initialize(params)
        @confidence_level_id = [params[:confidence_level_id]].flatten.compact
        @options = params.permit(:created_after, :created_before, on: [], by: [], id: []) 
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          Queries::Annotator.annotator_params(options, ::Confidence),
          matching_confidence_level_id,
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [Arel::Node, nil]
      def matching_confidence_level_id
        !confidence_level_id.empty? ? table[:confidence_level_id].eq_any(confidence_level_id)  : nil
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          ::Confidence.where(and_clauses)
        else
          ::Confidence.none
        end
      end

      # @return [Arel::Table]
      def table
        ::Confidence.arel_table
      end
    end
  end
end
