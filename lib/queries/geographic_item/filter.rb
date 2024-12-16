module Queries
  module GeographicItem

    def self.st_union(geographic_item_scope)
      ::GeographicItem
        .select(
          ::GeographicItem.st_union_sql(::GeographicItem.geography_as_geometry)
        )
        .where(id: geographic_item_scope.pluck(:id))
    end

    class Filter < Query::Filter
      PARAMS = [
        :geographic_item_id
      ].freeze

      # @return Array
      attr_accessor :geographic_item_id

      # @param [Hash] params
      def initialize(query_params)
        super

        @geographic_item_id = params[:geographic_item_id]
      end

      def geographic_item_id
        [@geographic_item_id].flatten.compact
      end

    end

  end
end
