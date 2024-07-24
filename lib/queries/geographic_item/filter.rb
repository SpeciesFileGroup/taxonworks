module Queries
  module GeographicItem

    def self.st_union(geographic_item_scope)
      ::GeographicItem.select(
        ::GeographicItem.st_union_sql(::GeographicItem::GEOMETRY_SQL)
      )
      .where(id: geographic_item_scope.pluck(:id))
    end

  end
end
