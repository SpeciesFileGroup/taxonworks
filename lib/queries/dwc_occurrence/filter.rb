module Queries
  module DwcOccurrence

    # Keep this minimal, in pricinple filtering should be done on the base objects, not the core here.
    class Filter < Query::Filter
      include Queries::Helpers
      include Queries::Concerns::Users

      PARAMS = [
        :dwc_occurrence_id,
        :dwc_occurence_object_type,
        :dwc_occurence_object_id,

        dwc_occurence_object_type: [],
        dwc_occurence_object_id: [],
        dwc_occurrence_id: [],
      ].freeze

      # @params dwc_occurrence_id [Integer, Array, nil]
      #   the TW native id, *not* the occurrenceID
      attr_accessor :dwc_occurrence_id

      # Used independantly now, not paired
      attr_accessor :dwc_occurrence_object_id
      attr_accessor :dwc_occurrence_object_type

      def initialize(query_params)
        super
        @dwc_occurrence_id = params[:dwc_occurrence_id]
        @dwc_occurrence_object_id = params[:dwc_occurrence_object_id]
        @dwc_occurrence_object_type = params[:dwc_occurrence_object_type]
      end

      def dwc_occurrence_id
        [@dwc_occurrence_id].flatten.compact
      end

      def dwc_occurrence_object_id
        [@dwc_occurrence_object_id].flatten.compact
      end

      def dwc_occurrence_object_type
        [@dwc_occurrence_object_type].flatten.compact
      end

      def dwc_occurrence_id_facet
        return nil if dwc_occurrence_id.empty?
        table[:dwc_occurrence_id].eq_any(dwc_occurrence_id)
      end

      def dwc_occurrence_object_id_facet
        return nil if dwc_occurrence_object_id.empty?
        table[:dwc_occurrence_object_id].eq_any(dwc_occurrence_object_id)
      end

      def dwc_occurrence_object_type_facet
        return nil if dwc_occurrence_object_type.empty?
        table[:dwc_occurrence_object_type].eq_any(dwc_occurrence_object_type)
      end

      def base_and_clauses
        [ dwc_occurrence_id_facet,
          dwc_occurrence_object_id_facet,
          dwc_occurrence_object_type_facet,
        ]
      end

    end
  end
end
