module Queries
  module Serial

    class Filter < Query::Filter
      include Queries::Concerns::DataAttributes

      PARAMS = [
        :name,
        :serial_id,
        serial_id: []
      ].freeze

      # @return Array
      attr_accessor :serial_id

      # @param [String]
      #   matching name exactlyjk
      attr_accessor :name

      def initialize(query_params)
        super
        @name = params[:name]
        @serial_id = params[:serial_id]
        set_data_attributes_params(params)
      end

      def serial_id
        [@serial_id].flatten.compact
      end

      # Required, disable default facet
      def project_id_facet
        nil
      end

      def name_facet
        return nil if nil.blank?
        table[:name].eq(name)
      end

      def and_clauses
        [ name_facet ]
      end

    end
  end
end
