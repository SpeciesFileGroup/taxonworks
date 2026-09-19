module Queries
  module AssertedEnvironment
    class Autocomplete < Query::Autocomplete

      def initialize(string, project_id: nil)
        super
      end

      # AssertedEnvironment has no free-text `name` column (see the model), so,
      # unlike most Autocomplete classes, we do not use `autocomplete_named`/
      # `autocomplete_exactly_named` - there is no `name` column for those to
      # match against.

      def autocomplete_uri_label_contains_match
        return nil if query_string.length < 2
        base_query.where('asserted_environments.uri_label ILIKE ?', '%' + query_string + '%').limit(20)
      end

      def autocomplete_uri_exact
        return nil if query_string.length < 10
        base_query.where(uri: query_string).limit(20)
      end

      def autocomplete_uri_ends_with
        return nil if query_string.length < 3
        base_query.where('asserted_environments.uri ILIKE ?', '%' + query_string).limit(20)
      end

      # Matching by ENVO term alone can't distinguish two assertions with the
      # same uri_label on different objects (see asserted_environment_tag),
      # so also let the object's own label reach its AssertedEnvironments -
      # one subquery per polymorphic type (mirrors
      # Queries::AnatomicalPart::Autocomplete's origin_otu/taxon_name join).

      def autocomplete_collecting_event_object
        return nil if query_string.length < 2
        base_query
          .joins("JOIN collecting_events ON collecting_events.id = asserted_environments.asserted_environment_object_id AND asserted_environments.asserted_environment_object_type = 'CollectingEvent'")
          .where('collecting_events.cached ILIKE ?', '%' + query_string + '%')
          .limit(20)
      end

      def autocomplete_otu_object_name
        return nil if query_string.length < 2
        base_query
          .joins("JOIN otus ON otus.id = asserted_environments.asserted_environment_object_id AND asserted_environments.asserted_environment_object_type = 'Otu'")
          .where('otus.name ILIKE ?', '%' + query_string + '%')
          .limit(20)
      end

      def autocomplete_otu_object_taxon_name
        return nil if query_string.length < 2
        base_query
          .joins("JOIN otus ON otus.id = asserted_environments.asserted_environment_object_id AND asserted_environments.asserted_environment_object_type = 'Otu'")
          .joins('JOIN taxon_names ON taxon_names.id = otus.taxon_name_id')
          .where('taxon_names.cached ILIKE ?', '%' + query_string + '%')
          .limit(20)
      end

      def autocomplete_gazetteer_object
        return nil if query_string.length < 2
        base_query
          .joins("JOIN gazetteers ON gazetteers.id = asserted_environments.asserted_environment_object_id AND asserted_environments.asserted_environment_object_type = 'Gazetteer'")
          .where('gazetteers.name ILIKE ?', '%' + query_string + '%')
          .limit(20)
      end

      def updated_queries
        queries = [
          autocomplete_exact_id,
          autocomplete_uri_label_contains_match,
          autocomplete_uri_exact,
          autocomplete_uri_ends_with,
          autocomplete_collecting_event_object,
          autocomplete_otu_object_name,
          autocomplete_otu_object_taxon_name,
          autocomplete_gazetteer_object
        ]

        queries.compact!

        return [] if queries.empty?

        project_queries = []

        queries.each do |q|
          a = project_id.present? ? q.where(project_id:) : q
          project_queries.push a
        end

        project_queries
      end

      # @return [Array]
      def autocomplete
        queries = updated_queries

        result = []

        queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 19
        end

        result[0..19]
      end

    end
  end
end
