module Queries
  module Attribution

    class Filter < Query::Filter

      # General annotator options handling
      # happens directly on the params as passed
      # through to the controller, keep them
      # together here
      attr_accessor :options

      # @params params [ActionController::Parameters]
      def initialize(params)
        @options = params
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        [ Queries::Annotator.annotator_params(options, ::Attribution) ]
      end

    end
  end
end
