module Queries
  module Tag 

    # !! does not inherit from base query
    class Filter 

      # General annotator options handling 
      # happens directly on the params as passed
      # through to the controller, keep them
      # together here
      attr_accessor :options

      # Params specific to Tag 

      # Array, Integer
      attr_accessor :keyword_id

      # @params params [ActionController::Parameters]
      def initialize(params)
        @keyword_id = [params[:keyword_id]].flatten.compact
        @options = params
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          ::Queries::Annotator.annotator_params(options, ::Tag),
          matching_keyword_id,
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [Arel::Node, nil]
      def matching_keyword_id
        !keyword_id.empty? ? table[:keyword_id].eq_any(keyword_id)  : nil
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          ::Tag.where(and_clauses)
        else
          ::Tag.all
        end
      end

      # @return [Arel::Table]
      def table
        ::Tag.arel_table
      end
    end
  end
end
