module Queries
  module CollectingEvent
    class Autocomplete < Queries::Query
      
      # @params string [String]
      # @params [Hash] args
      def initialize(string, project_id: nil)
        super
      end

      def base_query
        ::CollectingEvent.select('collecting_events.*')
      end

      def autocomplete_start_date_wild_card(field = :verbatim_locality) 
        a = with_start_date 
        b = fragments
        return nil if a.nil? || b.empty? || field.nil?
        base_query.where( a.and(table[field].matches(b.join)).to_sql).limit(20)
      end

      def autocomplete_verbatim_trip_identifier_match
        base_query.where( table[:verbatim_trip_identifier].matches(query_string + '%').to_sql).limit(20)
      end

      def autocomplete_verbatim_locality_wildcard_end
        return nil if query_string.length < 7
        base_query.where( table[:verbatim_locality].matches(query_string + '%').to_sql).limit(20)
      end

      def autocomplete_verbatim_locality_wildcard_end_starting_year
        a = years 
        return nil if query_string.length < 7 || a.empty?
        base_query.where(
          table[:start_date_year].eq_any(a).
          and( table[:verbatim_locality].matches(fragments.join))
          .to_sql)
          .limit(20)
      end

      # @return [Array]
      #   TODO: optimize limits
      def autocomplete
        queries = [
          autocomplete_exact_id,
          autocomplete_identifier_cached_exact,
          autocomplete_identifier_identifier_exact,
          autocomplete_identifier_cached_like,

          autocomplete_verbatim_trip_identifier_match,
          autocomplete_start_date_wild_card(:verbatim_locality), 
          autocomplete_start_date_wild_card(:cached),

          autocomplete_start_date,
          autocomplete_verbatim_locality_wildcard_end,
          autocomplete_verbatim_locality_wildcard_end_starting_year,
          autocomplete_cached_wildcard_anywhere,

          # others?
          # - verbatim locality exact match (?) start date
          # - ce_cached wildcard wrapped autocomplete start date
          # - date (exact date)
        ]

        queries.compact!

        return [] if queries.nil?
        updated_queries = []

        queries.each_with_index do |q ,i|
          a = q.where(project_id: project_id) if project_id
          a ||= q 
          updated_queries[i] = a
        end

        result = []
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 39 
        end
        result[0..39]
      end

      # @return [Arel::Table]
      def table
        ::CollectingEvent.arel_table
      end

    end
  end
end
