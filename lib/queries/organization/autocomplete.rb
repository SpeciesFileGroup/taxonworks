module Queries
  module Organization

    # Autocomplete for Organization.
    #
    # Organizations are shared across projects and are not referenced through
    # Roles here (Role-scoped lookups belong in a Role/Person context), so this
    # matches directly on the Organization name columns and on any attached
    # Identifier.
    class Autocomplete < Query::Autocomplete

      # @return [ActiveRecord::Relation]
      #   legal_name matches the query string exactly
      def autocomplete_exact_legal_name
        base_query.where(table[:legal_name].eq(query_string).to_sql).limit(20)
      end

      # @return [ActiveRecord::Relation]
      #   alternate_name matches the query string exactly
      def autocomplete_exact_alternate_name
        base_query.where(table[:alternate_name].eq(query_string).to_sql).limit(20)
      end

      # @return [ActiveRecord::Relation, nil]
      #   name starts with the query string
      def autocomplete_name_wildcard_end
        return nil if query_string.length < 2
        base_query.where(table[:name].matches(end_wildcard).to_sql).limit(20)
      end

      # @return [ActiveRecord::Relation]
      #   name, legal_name or alternate_name matches all query pieces in order,
      #   e.g. "nat hist" matches "Natural History Museum"
      def autocomplete_ordered_wildcard_pieces_in_name
        base_query.where(
          table[:name].matches(wildcard_pieces)
            .or(table[:legal_name].matches(wildcard_pieces))
            .or(table[:alternate_name].matches(wildcard_pieces))
            .to_sql
        ).limit(20)
      end

      # @return [ActiveRecord::Relation, nil]
      #   name matches all query fragments, unordered, e.g. "hist nat" matches
      #   "Natural History Museum"
      def autocomplete_wildcard_in_name
        b = fragments
        return nil if b.empty?
        base_query.where(table[:name].matches_all(b).to_sql).limit(20)
      end

      # @return [Array]
      def autocomplete
        return [] if query_string.blank?

        queries = [
          autocomplete_exact_id,
          autocomplete_exactly_named,
          autocomplete_exact_legal_name,
          autocomplete_exact_alternate_name,
          autocomplete_identifier_identifier_exact,
          autocomplete_identifier_cached_exact,
          autocomplete_name_wildcard_end,
          autocomplete_ordered_wildcard_pieces_in_name,
          autocomplete_wildcard_in_name,
          autocomplete_identifier_cached_like.limit(20)
        ]

        queries.compact!

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
