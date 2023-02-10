module Queries
  module Documentation

    class Filter < Query::Filter

      PARAMS = [
        :options,
        :source_id,
        :documentation_id,
        source_id: [],
        documentation_id: []
      ].freeze

      attr_accessor :documentation_id

      # TODO: remove
      # General annotator options handling
      # happens directly on the params as passed
      # through to the controller, keep them
      # together here
      attr_accessor :options

      # Params specific to Documentation

      # Not used!? Why here?
      # Array, Integer
      attr_accessor :source_id

      # @params params [ActionController::Parameters]
      def initialize(query_params)
        @options = query_params
        super
        @source_id = params[:source_id]
        @documentation_id = params[:documentation_id]
      end

      def documentation_id
        [@documentation_id].flatten.compact
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        [ ::Queries::Annotator.annotator_params(options, ::Documentation) ]
      end

    end
  end
end
