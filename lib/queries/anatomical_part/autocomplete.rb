module Queries
  module AnatomicalPart
    class Autocomplete < Query::Autocomplete

      def initialize(string, project_id: nil)
        super
      end

      def autocomplete_uri_label_contains_match
        return nil if query_string.length < 2
        base_query.where('anatomical_parts.uri_label ILIKE ?', '%' + query_string + '%').limit(20)
      end

      def autocomplete_uri_exact
        return nil if query_string.length < 10
        base_query.where(uri: query_string).limit(20)
      end

      def autocomplete_uri_ends_with
        return nil if query_string.length < 3
        base_query.where('anatomical_parts.uri ILIKE ?', '%' + query_string).limit(20)
      end

      def updated_queries
        queries = [
          autocomplete_exact_id,
          autocomplete_named,
          autocomplete_uri_label_contains_match,
          autocomplete_uri_exact,
          autocomplete_uri_ends_with
        ]

        queries.compact!

        return [] if queries.empty?

        project_queries = []

        queries.each do |q|
          a = q.where(project_id:) if project_id.present?
          project_queries.push a
        end

        project_queries
      end

      # @return [Array]
      def autocomplete
        queries = updated_queries

        result = []

        queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 19
        end

        result[0..19]
      end

    end
  end
end
