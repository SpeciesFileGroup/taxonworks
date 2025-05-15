module Queries
  module GeographicItem

    # DEPRECATED, unused
    def self.st_union(geographic_item_scope)
      ::GeographicItem
        .select(
          ::GeographicItem.st_union_sql(::GeographicItem.geography_as_geometry)
        )
        .where(id: geographic_item_scope.pluck(:id))
    end

    def self.st_union_text(geographic_item_scope)
      ::GeographicItem
        .with(u:
          ::GeographicItem
            .select(
              ::GeographicItem
                .st_union_sql(::GeographicItem.geography_as_geometry)
            )
            .where(id: geographic_item_scope.pluck(:id))
        )
        .from('u')
        .select(
          ::GeographicItem.st_as_text_sql(Arel.sql('u.st_union')),
          ::GeographicItem.st_geometry_type(Arel.sql('u.st_union'))
        )
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
