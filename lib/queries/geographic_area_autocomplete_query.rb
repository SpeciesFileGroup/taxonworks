module Queries

  class GeographicAreaAutocompleteQuery <  Queries::Query

    # TODO: use or_clauses
    # @return [String]
    def where_sql
      named.to_sql
    end

    # @return [Scope]
    def all
      (
        GeographicArea.where(name: query_string).all +
        GeographicArea.joins(parent_child_join).where(Arel.sql(parent_child_where.to_sql)).limit(5).all +
        GeographicArea.where(Arel.sql(where_sql)).includes(:geographic_area_type, :geographic_items).order('length(name)').limit(dynamic_limit).all
      ).flatten.compact.uniq
    end

    # @return [Arel::Table]
    def table
      GeographicArea.arel_table
    end

  end
end
