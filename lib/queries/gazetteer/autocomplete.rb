module Queries
  module Gazetteer
    class Autocomplete < Query::Autocomplete

      include Queries::Concerns::AlternateValues

      def initialize(string, **params)
        set_alternate_value(params)
        super
      end

      def autocomplete_iso_a2
        return nil if query_string.length != 2
        ::Gazetteer.where('iso_3166_a2 ILIKE ?', query_string)
      end

      def autocomplete_iso_a3
        return nil if query_string.length != 3
        ::Gazetteer.where('iso_3166_a3 ILIKE ?', query_string)
      end

      def updated_queries
        queries = [
          autocomplete_named,
          autocomplete_exact_id,
          matching_alternate_value_on(:name),
          autocomplete_iso_a2,
          autocomplete_iso_a3
        ]

        queries.compact!
        return [] if queries.empty?

        updated_queries = []

        queries.each do |q|
          a = q.where(project_id:) if project_id.present?
          updated_queries << a
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
