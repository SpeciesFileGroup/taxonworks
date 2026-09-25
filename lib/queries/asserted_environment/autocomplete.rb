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
        autocomplete_object('CollectingEvent', ::Queries::CollectingEvent::Autocomplete)
      end

      def autocomplete_otu_object
        autocomplete_object('Otu', ::Queries::Otu::Autocomplete)
      end

      def autocomplete_gazetteer_object
        autocomplete_object('Gazetteer', ::Queries::Gazetteer::Autocomplete)
      end

      # The object's Autocomplete is run scoped to only those objects that
      # have an AssertedEnvironment in this project. This keeps it fast
      # regardless of how many objects of that type exist, and prevents
      # matching objects without asserted environments from filling the
      # object Autocomplete's own result limit.
      # @param object_type [String]
      # @param object_autocomplete_class [Class]
      # @return [Scope, nil]
      def autocomplete_object(object_type, object_autocomplete_class)
        return nil if query_string.length < 3

        asserted_object_ids = ::AssertedEnvironment
          .where(asserted_environment_object_type: object_type)
        asserted_object_ids = asserted_object_ids.where(project_id:) if project_id.present?
        asserted_object_ids = asserted_object_ids.select(:asserted_environment_object_id)

        ids = object_type.constantize.where(id: asserted_object_ids).scoping do
          object_autocomplete_class.new(query_string, project_id:).autocomplete.map(&:id)
        end

        return nil if ids.empty?
        base_query.where(asserted_environment_object_type: object_type, asserted_environment_object_id: ids)
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
