module Queries
  module Container
    class Autocomplete < Query::Autocomplete

      def base_queries
        queries = [
          autocomplete_identifier_cached_exact,
          autocomplete_identifier_identifier_exact,
          autocomplete_exact_id, 
          autocomplete_identifier_cached_like,
        ]

        queries.compact! 

        return [] if queries.nil?
        updated_queries = []

        queries.each_with_index do |q ,i|
          a = q.where(project_id: project_id) if project_id
          a ||= q 
          updated_queries[i] = a
        end
        updated_queries
      end

      def autocomplete
        updated_queries = base_queries

        result = []
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 39 
        end
        result[0..39]
      end

    end
  end
end
