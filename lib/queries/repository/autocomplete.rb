module Queries

  class Repository::Autocomplete < Queries::Query

    include Queries::Concerns::AlternateValues

    # @param [Hash] args
    def initialize(string, params = {})
      set_identifier(params)
      set_alternate_value(params)
      super
    end

    def base_query
        ::Repository.select('repositories.*')
    end

    # @return [Scope]
    def autocomplete_acronym_match
      base_query.where(
        table[:acronym].matches_any(terms).to_sql
      ).limit(20)
    end

    def autocomplete_alternate_values_acronym
      matching_alternate_value_on(:acronym).limit(20)
    end

    def autocomplete_alternate_values_name
      matching_alternate_value_on(:name).limit(20)
    end

    # @return [Array]
    def autocomplete
      return [] if query_string.blank?
      queries = [
        autocomplete_acronym_match,
        autocomplete_exact_id,
        autocomplete_exactly_named,
        autocomplete_identifier_identifier_exact,
        autocomplete_named,
        autocomplete_alternate_values_acronym,
        autocomplete_alternate_values_name
      ]

      queries.compact!

      result = []
      queries.each do |q|
        result += q.to_a
        result.uniq!
        break if result.count > 19
      end
      result[0..19]
    end

    # @return [Arel::Table]
    def table
      ::Repository.arel_table
    end

  end
end
