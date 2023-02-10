module Queries
  module Attribution

    class Filter < Query::Filter

      PARAMS = [
        :options,
        :attriution_id,
        attribution_id: []
      ].freeze

      # General annotator options handling
      # happens directly on the params as passed
      # through to the controller, keep them
      # together here
      attr_accessor :options

      attr_accessor :attribution_id

      def initialize(query_params)
        @options = query_params
        super
        @attribution_id = params[:attribution_id]
      end

      def attribution_id
        [@attribution_id].flatten.compact
      end

      def and_clauses
        [ Queries::Annotator.annotator_params(options, ::Attribution) ]
      end

    end
  end
end
