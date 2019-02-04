module Queries
  module Organization
    class Autocomplete < Queries::Query
      
      # @params string [String]
      # @params [Hash] args
      def initialize(string)
        super
      end

      def base_query
        ::Organization.select('organizations.*')
      end

#     def autocomplete_start_date_wild_card(field = :verbatim_locality) 
#       a = with_start_date 
#       b = fragments
#       return nil if a.nil? || b.empty? || field.nil?
#       base_query.where( a.and(table[field].matches(b.join)).to_sql).limit(20)
#     end

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

      # @return [Arel::Table]
      def table
        ::Organization.arel_table
      end

    end
  end
end
