module Queries
  module Organization
    class Autocomplete < Query::Autocomplete
      
      # @params string [String]
      # @params [Hash] args
      def initialize(string)
        super
      end

      def autocomplete_name_wildcard_end
        return nil if query_string.length < 2 
        base_query.where( table[:name].matches(query_string + '%').to_sql).limit(20)
      end

      # @return [Array]
      #   TODO: optimize limits
      def autocomplete
        queries = [
          autocomplete_identifier_cached_like,
          autocomplete_name_wildcard_end
        ]

        queries.compact!

        return [] if queries.nil?

        result = []
        queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 39 
        end
        result[0..39]
      end

    end
  end
end
