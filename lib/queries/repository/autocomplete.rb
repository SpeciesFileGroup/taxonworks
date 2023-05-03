module Queries

  class Repository::Autocomplete < Queries::Query

    include Queries::Concerns::AlternateValues

    # @param [Hash] args
    def initialize(string, **params)
      set_identifier(params)
      set_alternate_value(params)
      super
    end

    # @return [Arel::Table]
    def table
      ::Repository.arel_table
    end

    def base_query
      ::Repository.select('repositories.*')
    end

    # @return [Scope]
    def autocomplete_acronym_match
      base_query.where(
        table[:acronym].matches_any(terms).to_sql
      )
    end

    # @return [Scope]
    def autocomplete_exact_acronym
      base_query.where(
        table[:acronym].eq(query_string).to_sql
      )
    end

    def autocomplete_alternate_values_acronym
      matching_alternate_value_on(:acronym)
    end

    def autocomplete_alternate_values_name
      matching_alternate_value_on(:name)
    end

    # @return [Array]
    def autocomplete
      return [] if query_string.blank?
      queries = [
        [autocomplete_exact_id, nil ],
        [autocomplete_exactly_named, nil],
        [autocomplete_exact_acronym, nil],
        [autocomplete_identifier_identifier_exact, nil],
        [autocomplete_acronym_match.limit(5), nil],
        [autocomplete_named, true ],
        [autocomplete_alternate_values_acronym.limit(20), true ],
        [autocomplete_alternate_values_name.limit(20), true ]
      ]

      queries.delete_if{|a,b| a.nil?} # Note this pattern differs because [[]] so we don't use compact. /lib/queries/source/autocomplete.rb follows same pattern

      result = []

      queries.each do |q, scope|
        a = q
        if project_id && scope
          # TODO: there are now 2 repository references, see also current_repository_id
          a = a.select("repositories.*, COUNT(collection_objects.id) AS use_count, CASE WHEN collection_objects.project_id = #{Current.project_id} THEN collection_objects.project_id ELSE NULL END AS in_project")
            .left_outer_joins(:collection_objects)
            .where('collection_objects.project_id = ? OR collection_objects.project_id IS DISTINCT FROM ?', project_id, project_id)
            .group('repositories.id, collection_objects.project_id')
            .order('in_project, use_count DESC')
        end

        a ||= q

        result += a.to_a
        result.uniq!
        break if result.count > 40
      end
      result[0..40]
    end
  end
end
