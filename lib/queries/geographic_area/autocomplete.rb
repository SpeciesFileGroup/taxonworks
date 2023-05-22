module Queries
  module GeographicArea
    class Autocomplete < Query::Autocomplete

      include Queries::Concerns::AlternateValues
      include Queries::Concerns::Tags

      def initialize(string, **params)
        set_tags_params(params)
        set_alternate_value(params)
        super
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
          [ ::GeographicArea.where(id: query_string).all, false ],
          [ ::GeographicArea.where(name: query_string).all, true ],
          [ ::GeographicArea.joins(:alternate_values).where('alternate_values.value ILIKE ?', query_string).all, true ],
          [ ::GeographicArea.joins(parent_child_join).where(Arel.sql(parent_child_where.to_sql)).limit(5).all, true ],
          [ ::GeographicArea.where(Arel.sql(where_sql)).limit(dynamic_limit).all, true ],
          [ autocomplete_exact_id, false ],
          [ autocomplete_identifier_cached_exact, false ],
          [ autocomplete_identifier_identifier_exact, false ],
          [ autocomplete_alternate_values_name.limit(20), true ]
        ]

        queries.compact!

        updated_queries = []
        pr_id = project_id.join(',') if project_id

        queries.each_with_index do |q, i|
          a = q[0]

          if q[1] # do not use extended query for identifiers
            if project_id.present?

              if !a.nil?
                a = a.left_outer_joins(:asserted_distributions)
                     .left_outer_joins(:collecting_events)
                     .select("geographic_areas.*, (COUNT(collecting_events.id) + COUNT(asserted_distributions.id)) AS use_count, CASE WHEN asserted_distributions.project_id IN (#{pr_id}) THEN asserted_distributions.project_id WHEN collecting_events.project_id IN (#{pr_id}) THEN collecting_events.project_id ELSE NULL END AS in_project")
                     .group('geographic_areas.id, collecting_events.project_id, asserted_distributions.project_id')
                     .order('in_project, use_count DESC')
              end
            end
          end
          updated_queries[i] = a
        end
        result = []
        updated_queries.compact!
        updated_queries.each do |q|
          result += q.includes(:geographic_areas_geographic_items).to_a
          result.uniq!
          break if result.count > 19
        end
        result = result[0..19]
      end

    end
  end
end
