module Queries
  module AssertedEnvironment
    class Autocomplete < Query::Autocomplete

      def initialize(string, project_id: nil)
        super
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

      # Matching by ENVO term alone can't distinguish two assertions with the
      # same uri_label on different objects (see asserted_environment_tag), so
      # also let the object's own label reach its AssertedEnvironments - one
      # subquery per polymorphic type, each delegating to that object's own
      # (already comprehensive) Autocomplete class rather than reimplementing
      # a narrower match here.

      def autocomplete_collecting_event_object
        return nil if query_string.length < 3
        ids = ::Queries::CollectingEvent::Autocomplete.new(query_string, project_id:).autocomplete.map(&:id)
        return nil if ids.empty?
        base_query.where(asserted_environment_object_type: 'CollectingEvent', asserted_environment_object_id: ids)
      end

      def autocomplete_otu_object
        return nil if query_string.length < 3
        ids = ::Queries::Otu::Autocomplete.new(query_string, project_id:).autocomplete.map(&:id)
        return nil if ids.empty?
        base_query.where(asserted_environment_object_type: 'Otu', asserted_environment_object_id: ids)
      end

      def autocomplete_gazetteer_object
        return nil if query_string.length < 3
        ids = ::Queries::Gazetteer::Autocomplete.new(query_string, project_id:).autocomplete.map(&:id)
        return nil if ids.empty?
        base_query.where(asserted_environment_object_type: 'Gazetteer', asserted_environment_object_id: ids)
      end

      def updated_queries
        queries = [
          autocomplete_exact_id,
          autocomplete_uri_label_contains_match,
          autocomplete_uri_exact,
          autocomplete_uri_ends_with,
          autocomplete_collecting_event_object,
          autocomplete_otu_object,
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
