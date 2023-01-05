module Queries
  module Serial
    class Autocomplete < Query::Autocomplete

      # @param [Hash] args
      def initialize(string, project_id: nil)
        super
      end

      # @return [Scope]
      def base_query
        ::Serial.select('serials.*')
      end

      # @return [Array]
      def autocomplete
        queries = [
          autocomplete_exact_name,
          #autocomplete_exact_alternate_value,
          autocomplete_exact_alternate_value('name', 'AlternateValue::Translation'),
          autocomplete_exact_alternate_value('name', 'AlternateValue::Abbreviation'),

          autocomplete_begining_name,
          #autocomplete_begining_alternate_value,
          autocomplete_begining_alternate_value('name', 'AlternateValue::Translation'),
          autocomplete_begining_alternate_value('name', 'AlternateValue::Abbreviation'),

          autocomplete_ordered_wildcard_pieces_in_name,
          #autocomplete_ordered_wildcard_alternate_value,
          autocomplete_ordered_wildcard_alternate_value('name', 'AlternateValue::Translation'),
          autocomplete_ordered_wildcard_alternate_value('name', 'AlternateValue::Abbreviation')
        ]

        queries.compact!

        updated_queries = []
        queries.each_with_index do |q ,i|
          a = q
          if project_id
            # a = q.joins(:project_sources).where(member_of_project_id.to_sql) if project_id && limit_to_project
            a = a.select("serials.*, COUNT(project_sources.source_id) AS use_count, CASE WHEN project_sources.project_id = #{Current.project_id} THEN project_sources.project_id ELSE NULL END AS in_project")
                 .left_outer_joins(:sources)
                 .joins('LEFT OUTER JOIN project_sources ON sources.id = project_sources.source_id')
                 .where('project_sources.project_id = ? OR project_sources.project_id IS DISTINCT FROM ?', project_id, project_id)
                 .group('serials.id, project_sources.project_id')
                 .order('in_project, use_count DESC')
          end
          a ||= q
          updated_queries[i] = a
        end

        result = []
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 19
        end
        if result.first.try(:use_count).nil?
          return result[0..19]
        else
          return result.sort_by{|i| -i.use_count}[0..19]
        end
      end

      # @return [ActiveRecord::Relation]
      #    match exact name
      def autocomplete_exact_name
        a = table[:name].eq(query_string)
        base_query.where(a.to_sql).limit(20)
      end

      # @return [ActiveRecord::Relation]
      #    match begining of name
      def autocomplete_begining_name
        a = table[:name].matches(query_string + '%')
        base_query.where(a.to_sql).limit(20)
      end

      # @return [ActiveRecord::Relation]
      def autocomplete_ordered_wildcard_pieces_in_name
        a = table[:name].matches(wildcard_pieces)
        base_query.where( a.to_sql).limit(10)
      end

      # TODO: these three should be factored out to just the join, made more Arel like
      #
      def autocomplete_ordered_wildcard_alternate_value(attribute = 'name', type = 'AlternateValue')
        ::Serial.joins(:alternate_values).where(
          alternate_value_table[:type].eq(type).and(
          alternate_value_table[:alternate_value_object_attribute].eq(attribute).
          and(alternate_value_table[:value].matches(wildcard_pieces))).to_sql
        ).limit(10)
      end

      def autocomplete_exact_alternate_value(attribute = 'name', type = 'AlternateValue')
        ::Serial.joins(:alternate_values).where(
          alternate_value_table[:type].eq(type).and(
          alternate_value_table[:alternate_value_object_attribute].eq(attribute).
          and(alternate_value_table[:value].eq(query_string))).to_sql
        ).limit(20)
      end

      def autocomplete_begining_alternate_value(attribute = 'name', type = 'AlternateValue')
        ::Serial.joins(:alternate_values).where(
          alternate_value_table[:type].eq(type).and(
          alternate_value_table[:alternate_value_object_attribute].eq(attribute).
          and(alternate_value_table[:value].matches(query_string + '%'))).to_sql
        ).limit(20)
      end

      #  def alternate_value_join
      #    table.join(alternate_value_table)
      #      .on(table[:id].eq(alternate_value_table[:alternate_value_object_id]).and(
      #        alternate_value_table[:alternate_value_object_type].eq('Serial')
      #      )
      #    )
      #  end

      # @return [Arel::Table]
      def alternate_value_table
        ::AlternateValue.arel_table
      end

      # @return [Arel::Table]
      def table
        ::Serial.arel_table
      end

    end
  end
end
