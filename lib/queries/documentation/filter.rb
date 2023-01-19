module Queries
  module Documentation

    class Filter < Query::Filter

      # General annotator options handling
      # happens directly on the params as passed
      # through to the controller, keep them
      # together here
      attr_accessor :options

      # Params specific to Documentation

      # Array, Integer
      attr_accessor :source_id

      # @params params [ActionController::Parameters]
      def initialize(params)
        @options = params
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          ::Queries::Annotator.annotator_params(options, ::Documentation),
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          ::Documentation.where(and_clauses)
        else
          ::Documentation.all
        end
      end

    end
  end
end
