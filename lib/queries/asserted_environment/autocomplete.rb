module Queries
  module AssertedEnvironment
    class Autocomplete < Query::Autocomplete

      DEFAULT_LIMIT = 20

      def initialize(string, project_id: nil, restrict_to: nil, limit: nil)
        super(string, project_id:, restrict_to:, limit:)
      end

      def autocomplete_uri_label_contains_match
        return nil if query_string.length < 3
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

      def autocomplete_collecting_event_object
        autocomplete_object('CollectingEvent', ::Queries::CollectingEvent::Autocomplete)
      end

      def autocomplete_otu_object
        autocomplete_object('Otu', ::Queries::Otu::Autocomplete)
      end

      def autocomplete_gazetteer_object
        autocomplete_object('Gazetteer', ::Queries::Gazetteer::Autocomplete)
      end

      # @param object_type [String]
      # @param object_autocomplete_class [Class]
      # @return [Scope, nil]
      def autocomplete_object(object_type, object_autocomplete_class)
        return nil if query_string.length < 3

        asserted_object_autocomplete(
          object_type:,
          object_autocomplete_class:,
          object_association: :asserted_environment_object
        )
      end

      # @return [Array]
      def autocomplete
        # Method names, built in turn, so that later queries (e.g. the object
        # ones, which run the object autocompletes) don't run once the
        # results are filled
        queries = %i[
          autocomplete_exact_id
          autocomplete_uri_label_contains_match
          autocomplete_uri_exact
          autocomplete_uri_ends_with
          autocomplete_collecting_event_object
          autocomplete_otu_object
          autocomplete_gazetteer_object
        ]

        result = []
        queries.each do |m|
          q = send(m)
          next if q.nil?

          q = q.where(project_id:) if project_id.present?
          result += apply_restriction(q).to_a
          result.uniq!
          break if result.count >= limit
        end

        result.first(limit)
      end

    end
  end
end
