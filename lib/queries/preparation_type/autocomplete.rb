module Queries
  module PreparationType
    class Autocomplete < Query::Autocomplete

      # @param [Hash] args
      def initialize(string)
        super
      end

      def updated_queries
        queries = [
          autocomplete_name_ilike,
        ]

        queries.compact!

        return [] if queries.empty?

        queries
      end

      # @return [Array]
      def autocomplete
        queries = updated_queries

        result = []
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 19
        end

        result[0..40]
      end

      def autocomplete_name_ilike
        ::PreparationType
          .where(named)
          .order(:name)
          .limit(20)
      end

    end
  end
end
