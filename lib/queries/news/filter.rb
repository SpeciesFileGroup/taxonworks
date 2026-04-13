module Queries
  module News
    class Filter < Query::Filter

      PARAMS =  [
        :type,
        :news_id,
        news_id: [],
        type: [],
      ].freeze

      # Array, Integer
      attr_accessor :news_id

      # Array, Integer
      attr_accessor :type

      def initialize(query_params)
        super
        @news_id = params[:news_id]
        @type = params[:type]
      end

      def type
        [@type].flatten.compact
      end

      def news_id
        [@news_id].flatten.compact
      end

      def type_facet
        return nil if type.empty?
        table[:type].in(type)
      end


      def and_clauses
        [
          type_facet
        ]
      end
    end
  end
end
