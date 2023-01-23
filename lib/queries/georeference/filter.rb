module Queries
  module Georeference
    class Filter < Query::Filter

      PARAMS = [
        :collecting_event_id,
        collecting_event_id: [],
      ]

      attr_accessor :collecting_event_id

      # @param [Hash] params
      def initialize(params)
        @collecting_event_id = params[:collecting_event_id]
      end

      def collecting_event_id
        [@collecting_event_id].flatten.compact.uniq
      end

      def matching_collecting_event_id
        return nil if collecting_event_id.empty?
        table[:collecting_event_id].eq_any(collecting_event_id)
      end

      def and_clauses
       [ matching_collecting_event_id,
        ].compact
      end

    end
  end
end
