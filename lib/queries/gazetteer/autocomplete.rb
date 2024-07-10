module Queries
  module Gazetteer
    class Autocomplete < Query::Autocomplete

      def initialize(string, project_id: nil)
        super
      end

      def autocomplete_text_contains_match
        return nil if query_string.length < 2
        base_query.where('gazetteers.name ilike ?', '%' + query_string + '%').limit(20)
      end

      def updated_queries
        queries = [
          autocomplete_text_contains_match,
        ]

        queries.compact!

        return [] if queries.empty?

        updated_queries = []

        queries.each do |q|
          a = q.where(project_id:) if project_id.present?
          updated_queries.push a
        end
        updated_queries
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
