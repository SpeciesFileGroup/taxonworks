module Queries
  module GeographicItem

    def self.st_union(geographic_item_scope)
      ::GeographicItem.select(
        ::GeographicItem.st_union_sql(::GeographicItem.geography_as_geometry)
      )
      .where(id: geographic_item_scope.pluck(:id))
    end

    class Filter < Query::Filter

    end

  end
end
