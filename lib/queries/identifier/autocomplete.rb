module Queries
  module Identifier
    class Autocomplete < Query::Autocomplete

      attr_accessor :identifier_object_types

      # @param [Hash] args
      def initialize(string, project_id: nil, identifier_object_types: [])
        @identifier_object_types = identifier_object_types || []
        # @exact = exact == 'true' ? true : (exact == 'false' ? false : nil)
        super
      end

      # @return [Arel:Nodes, nil]
      def and_clauses
        clauses = [
          is_identifier_object_type
        ].compact

        return nil if clauses.nil?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      def autocomplete
        queries = [
          autocomplete_exact_cached,
          autocomplete_exact_identifier,
          autocomplete_matching_cached,
          autocomplete_matching_cached_anywhere
        ]

        queries.compact!

        updated_queries = []
        queries.each_with_index do |q ,i|
          a = q.where(with_project_id.to_sql) if project_id.present?
          a = a.where(and_clauses.to_sql) if and_clauses
          a ||= q
          updated_queries[i] = a
        end

        result = []
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 29
        end
        result[0..29]
      end

      # @return [Arel::Nodes::<>, nil]
      def is_identifier_object_type
        return nil if identifier_object_types.empty?
        table[:identifier_object_type].eq_any(identifier_object_types)
      end

      def autocomplete_exact_cached
        base_query.where(with_cached.to_sql).limit(2)
      end

      def autocomplete_exact_identifier
        base_query.where(with_identifier_identifier.to_sql).limit(15)
      end

      def autocomplete_matching_cached
        base_query.where(match_wildcard_end_in_cached).order(Arel.sql('LENGTH(cached)')).limit(20)
      end

      def autocomplete_matching_cached_anywhere
        base_query.where(with_identifier_cached_wildcarded).order(Arel.sql('LENGTH(cached)')).limit(20)
      end

    end
  end
end
