module Queries
  module CollectingEvent
    class Autocomplete < Query::Autocomplete

      include ::Queries::Concerns::DateRanges
      include ::Queries::Concerns::Roles

      # @params string [String]
      # @params [Hash] args
      def initialize(string, project_id: nil)
        super
      end

      def base_query
        ::CollectingEvent.select('collecting_events.*')
      end

      def autocomplete_verbatim_label_md5
        return nil if query_string.to_s.length < 4
        md5 = Utilities::Strings.generate_md5(query_string)
        base_query.where( table[:md5_of_verbatim_label].eq(md5)).limit(3)
      end

      def autocomplete_matching_collectors
        return nil if no_terms?
        matching_person_cached(:collector).limit(20)
      end

      def autocomplete_start_date_wild_card(field = :verbatim_locality)
        a = with_start_date
        b = string_fragments
        return nil if a.nil? || b.empty? || field.nil?
        base_query.where( a.and(table[field].matches(b.join)).to_sql).limit(20)
      end

      def autocomplete_verbatim_trip_identifier_match
        base_query.where( table[:verbatim_trip_identifier].matches(end_wildcard).to_sql).limit(20)
      end

      def autocomplete_verbatim_collectors_wildcard
        return nil if query_string.length < 4
        base_query.where( table[:verbatim_collectors].matches(start_and_end_wildcard).to_sql).limit(20)
      end

      def autocomplete_verbatim_locality_wildcard_end
        return nil if query_string.length < 4
        base_query.where( table[:verbatim_locality].matches(end_wildcard).to_sql).limit(20)
      end

      def autocomplete_verbatim_date
        return nil if query_string.length < 4
        base_query.where( table[:verbatim_date].matches(start_and_end_wildcard).to_sql).limit(20)
      end

      def autocomplete_verbatim_habitat
        return nil if query_string.length < 4
        base_query.where( table[:verbatim_habitat].matches(start_and_end_wildcard).to_sql).limit(20)
      end

      def autocomplete_verbatim_latitude_or_longitude
        return nil if query_string.nil?
        base_query.where(
          table[:verbatim_latitude].matches(start_and_end_wildcard)
          .or(table[:verbatim_longitude].matches(start_and_end_wildcard)).to_sql
        ).limit(20)
      end

      def autocomplete_verbatim_locality_wildcard_end_starting_year
        a = years
        return nil if query_string.length < 7 || a.empty?
        base_query.where(
          table[:start_date_year].eq_any(a).
          and( table[:verbatim_locality].matches(string_fragments.join))
          .to_sql)
          .limit(20)
      end

      # @return [Array]
      #   TODO: optimize limits
      def autocomplete
        queries = [
          autocomplete_exact_id,
          autocomplete_verbatim_label_md5,
          autocomplete_identifier_identifier_exact,
          autocomplete_identifier_cached_exact,
          autocomplete_identifier_cached_like.limit(4),
          autocomplete_verbatim_trip_identifier_match,
          autocomplete_start_or_end_date,
          autocomplete_start_date_wild_card(:verbatim_locality),
          autocomplete_start_date_wild_card(:cached),
          autocomplete_matching_collectors,
          autocomplete_verbatim_latitude_or_longitude,
          autocomplete_verbatim_collectors_wildcard,
          autocomplete_verbatim_date,
          autocomplete_verbatim_habitat,
          autocomplete_verbatim_locality_wildcard_end,
          autocomplete_verbatim_locality_wildcard_end_starting_year,

          autocomplete_cached_wildcard_anywhere&.limit(20),
        ]

        queries.compact!

        return [] if queries.empty?
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
          break if result.count > 29
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
