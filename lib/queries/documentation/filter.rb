module Queries
  module Documentation

    class Filter < Query::Filter

      PARAMS = [
        :options,
        :source_id,
      ]

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
        [ ::Queries::Annotator.annotator_params(options, ::Documentation) ]
      end

    end
  end
end
