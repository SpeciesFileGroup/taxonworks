module Queries
  module BiologicalAssociationsGraph 
    class Autocomplete < Query::Autocomplete

      def initialize(string, project_id: nil)
        super(string, project_id: project_id)
      end

      def table
        ::BiologicalAssociationsGraph.arel_table
      end

      def base_queries
        queries = [
          autocomplete_exactly_named,
          autocomplete_named,
          autocomplete_exact_id,
          autocomplete_identifier_identifier_exact,
          autocomplete_identifier_cached_like,
        ]

        queries.compact!

        return [] if queries.nil?
        updated_queries = []

        queries.each_with_index do |q ,i|
          a = q.where(project_id: project_id) if project_id.present?
          a ||= q
          updated_queries[i] = a
        end

        updated_queries
      end

      # @return [Array]
      def autocomplete
        result = []
        base_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 39
        end
        result[0..39]
      end

    end
  end
end
