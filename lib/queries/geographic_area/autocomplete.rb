module Queries
  module GeographicArea
    class Autocomplete <  Queries::Query

      include Queries::Concerns::AlternateValues
      include Queries::Concerns::Tags

      def initialize(string, **params)
        set_identifier(params)
        set_tags_params(params)
        set_alternate_value(params)
        super
      end

      # @return [Scope]
      def base_query
        ::GeographicArea #.select('people.*')
      end

      # TODO: use or_clauses
      # @return [String]
      def where_sql
        named.to_sql
      end


      def autocomplete_alternate_values_name
        matching_alternate_value_on(:name)
      end

      # @return Array
      def autocomplete
        return [] if query_string.blank?
        queries = [
          ::GeographicArea.where(id: query_string).all,
          ::GeographicArea.where(name: query_string).all,
          ::GeographicArea.joins(parent_child_join).where(Arel.sql(parent_child_where.to_sql)).limit(5).all,
          ::GeographicArea.where(Arel.sql(where_sql)).includes(:geographic_area_type, :geographic_items).order(Arel.sql('LENGTH(name)')).limit(dynamic_limit).all,
           autocomplete_exact_id,
           autocomplete_identifier_cached_exact,
           autocomplete_identifier_identifier_exact,
           autocomplete_alternate_values_name.limit(20)
        ]

        queries.compact!

        result = []
        queries.each_with_index do |q, i|
          result += q.to_a
          result.uniq!
          break if result.count > 19
        end
        result = result[0..19]
      end

      # @return [Arel::Table]
      def table
        ::GeographicArea.arel_table
      end

    end
  end
end
