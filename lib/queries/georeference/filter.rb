module Queries
  module Georeference
    class Filter < Query::Filter

      PARAMS = [
        :collecting_event_id,
        collecting_event_id: [],
      ].freeze

      # @return Array
      attr_accessor :georeference_id

      # @return Array
      attr_accessor :collecting_event_id

      # @param [Hash] params
      def initialize(query_params)
        super

        @collecting_event_id = params[:collecting_event_id]
        @geoference_id = params[:georeference_id]
      end

      def georeference_id
        [@georeference_id].flatten.compact
      end

      def collecting_event_id
        [@collecting_event_id].flatten.compact.uniq
      end

      def collecting_event_id_facet
        return nil if collecting_event_id.empty?
        table[:collecting_event_id].eq_any(collecting_event_id)
      end

      def and_clauses
        [ collecting_event_id_facet ]
      end

    end
  end
end
