module Queries
  module ObservationMatrix
    class Filter < Query::Filter

      PARAMS = [
        :observation_matrix_id,
        :otu_id, 
        observation_matrix_id: [],
        otu_id: []
      ].freeze

      attr_accessor :otu_id

      attr_accessor :observation_matrix_id

      def initialize(query_params)
        super
        @observation_matrix_id = params[:observation_matrix_id]
        @otu_id = params[:otu_id]
      end


      def otu_id
        [@otu_id].flatten.compact
      end

      def observation_matrix_id
        [@observation_matrix_id].flatten.compact
      end

      def otu_id_facet
        return nil if otu_id.empty?
        table[:otu_id].eq_any(otu_id)
      end

      def and_clauses
        [ ]
      end

    end
  end
end
