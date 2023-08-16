module Queries
  module ObservationMatrix
    class Filter < Query::Filter

      PARAMS = [
        :observation_matrix_id,
        observation_matrix_id: []
      ].freeze

      attr_accessor :observation_matrix_id

      def initialize(query_params)
        super
        @observation_matrix_id = params[:observation_matrix_id]
      end

      def observation_matrix_id
        [@observation_matrix_id].flatten.compact
      end

      def and_clauses
        [ ]
      end

    end
  end
end
