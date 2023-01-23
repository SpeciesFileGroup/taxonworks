module Queries
  module ObservationMatrix
    class Filter < Query::Filter

      PARAMS = [
        :observation_matrix_id
      ]

      attr_accessor :observation_matrix_id

      def initialize(params = {})
        @observation_matrix_id = params[:observation_matrix_id]
      end

      def observation_matrix_id
        [@observation_matrix_id].flatten.compact
      end

      def observation_matrix_id_facet
        return nil if observation_matrix_id.empty?
        table[:id].eq_any(observation_matrix_id)
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        [ observation_matrix_id_facet ]
      end

    end
  end
end
