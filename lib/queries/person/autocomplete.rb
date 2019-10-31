module Queries
  module Person
    class Autocomplete < Queries::Query

      # @return [Array]
      # @param limit_to_role [String] any Role class, like `TaxonNameAuthor`, `SourceAuthor`, `SourceEditor`, `Collector` ... etc.
      attr_accessor :limit_to_roles

      # any project == all roles
      # project_id - the target project in general

      # @param [Hash] args
      def initialize(string, roles: :all)
        @limit_to_roles = roles
        super
      end

      # @return [Scope]
      def base_query
        ::Person.select('people.*')
      end

      # @return [Arel::Nodes::Equatity]
      def role_match
        a = roles_table[:type].eq_any(limit_to_roles)
        a = a.and(roles_table[:project_id].eq(project_id)) if !project_id.blank?
        a
      end

      # @return [Arel::Nodes::Equatity]
      def role_project_match
        roles_table[:project_id].eq(project_id)
      end

      # @return [Scope]
      def autocomplete_exact_match
        base_query.where(
          table[:cached].eq(normalize_name).to_sql
        ).limit(20)
      end

      def autocomplete_exact_last_name_match
        base_query.where(
          table[:last_name].eq(query_string).to_sql
        ).limit(20)
      end

      # @return [Scope]
      def autocomplete_exact_inverted
        base_query.where(
          table[:cached].eq(invert_name).to_sql
        ).limit(20)
      end

      # TODO: Use bibtex parser!!
      # @param [String] string
      # @return [String]
      def normalize(string)
        string.strip.split(/\s*\,\s*/, 2).join(', ')
      end

      # @return [String] simple name inversion
      #   given `Sarah Smith` return `Smith, Sarah`
      def invert_name
        normalize(
          query_string.split(/\s+/, 2).reverse.map(&:strip).join(', ')
        )
      end

      # @return [String]
      def normalize_name
        normalize(query_string)
      end

      # @return [Boolean]
      def roles_assigned?
        limit_to_roles.kind_of?(Array) && limit_to_roles.any?
      end

      # @return [Array]
      def autocomplete
        return [] if query_string.blank?
        queries = [
          autocomplete_exact_match,
          autocomplete_exact_inverted,
          autocomplete_identifier_cached_exact,
          autocomplete_identifier_identifier_exact,
          autocomplete_exact_last_name_match,
          autocomplete_ordered_wildcard_pieces_in_cached,
          autocomplete_cached_wildcard_anywhere, # in Queries::Query
          autocomplete_cached
        ]

        queries.compact!

        updated_queries = []
        queries.each_with_index do |q ,i|
          a = q.joins(:roles).where(role_match.to_sql) if roles_assigned?
          a ||= q
          updated_queries[i] = a
        end

        result = []
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 19
        end
        result[0..19]
      end

      # @return [Arel::Table]
      def table
        ::Person.arel_table
      end

      # @return [Arel::Table]
      def roles_table
        ::Role.arel_table
      end
    end
  end
end
