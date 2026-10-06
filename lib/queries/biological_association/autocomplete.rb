module Queries
  module BiologicalAssociation
    class Autocomplete < Query::Autocomplete

      DEFAULT_LIMIT = 50

      def initialize(string, project_id: nil, restrict_to: nil, limit: nil)
        super(string, project_id:, restrict_to:, limit:)
      end

      # @return [Scope]
      #   scoped to the project, so that queries that aren't joined to
      #   project-scoped records (e.g. #autocomplete_exact_id) are
      def base_query
        q = super
        q = q.where(project_id:) if project_id.any?
        q
      end

      # @return [ActiveRecord::Relation]
      #   the klass records that are the `side` (:subject or :object) of a
      #   biological_association in the project (and in restrict_to, when
      #   given). A candidate on a side is only useful if it is on that side
      #   of some biological association; unrestricted, candidates that
      #   aren't fill the subject/object autocompletes' limits and matching
      #   biological associations are missed (e.g. a genus search matching
      #   hundreds of species, few of which are in one).
      def side_restriction(klass, side)
        klass.where(
          id: apply_restriction(base_query)
            .where("biological_association_#{side}_type": klass.base_class.name)
            .reselect("biological_association_#{side}_id")
        )
      end

      # @return [Query::Autocomplete]
      #   an autocomplete_klass autocomplete restricted to klass records on
      #   `side` (see #side_restriction), and limited to #limit, so
      #   that it returns enough candidates to fill the results
      def side_autocomplete(autocomplete_klass, klass, side)
        @side_autocompletes ||= {}
        @side_autocompletes[[autocomplete_klass, side]] ||= autocomplete_klass
          .new(query_string, project_id:, restrict_to: side_restriction(klass, side), limit:)
      end

      # @return [Queries::Otu::Autocomplete]
      def otu_autocomplete(side)
        side_autocomplete(Queries::Otu::Autocomplete, ::Otu, side)
      end

      # @return [Queries::CollectionObject::Autocomplete]
      def collection_object_autocomplete(side)
        side_autocomplete(Queries::CollectionObject::Autocomplete, ::CollectionObject, side)
      end

      # @return [Queries::FieldOccurrence::Autocomplete]
      def field_occurrence_autocomplete(side)
        side_autocomplete(Queries::FieldOccurrence::Autocomplete, ::FieldOccurrence, side)
      end

      # @return [Queries::BiologicalRelationship::Autocomplete]
      def biological_relationship_autocomplete
        @biological_relationship_autocomplete ||= Queries::BiologicalRelationship::Autocomplete
          .new(query_string, project_id: project_id)
      end

      # @return [Queries::AnatomicalPart::Autocomplete]
      def anatomical_part_autocomplete(side)
        side_autocomplete(Queries::AnatomicalPart::Autocomplete, ::AnatomicalPart, side)
      end

      # @return [Array<BiologicalAssociation>]
      #   biological_associations where the subject or object (on `side`) is one of the
      #   related_klass records identified by `ids`, in `ids` order, at most
      #   results_allowed
      def joined_matches(related_table_name, related_type, side, ids, results_allowed)
        return [] if ids.empty?

        foreign_key_column = "biological_association_#{side}_id"
        type_column = "biological_association_#{side}_type"

        q = base_query
          .joins(
            "JOIN #{related_table_name} ON biological_associations.#{foreign_key_column} = #{related_table_name}.id " \
            "AND biological_associations.#{type_column} = '#{related_type}'"
          )
          .where(related_table_name.to_sym => { id: ids })
          # Keep the related autocomplete's ranking, so that the results cap
          # keeps the best matches
          .order(Arel.sql(
            "array_position(ARRAY[#{ids.map(&:to_i).join(',')}], #{related_table_name}.id), biological_associations.id"
          ))
          .limit(results_allowed)

        apply_restriction(q).to_a
      end

      def otu_matches(side, results_allowed)
        ids = otu_autocomplete(side).autocomplete_base.limit(results_allowed).pluck(:id)
        joined_matches('otus', 'Otu', side, ids, results_allowed)
      end

      def collection_object_matches(collection_object_query, side, results_allowed)
        ids = collection_object_query.limit(results_allowed).pluck(:id)
        joined_matches('collection_objects', 'CollectionObject', side, ids, results_allowed)
      end

      def field_occurrence_matches(field_occurrence_query, side, results_allowed)
        ids = field_occurrence_query.limit(results_allowed).pluck(:id)
        joined_matches('field_occurrences', 'FieldOccurrence', side, ids, results_allowed)
      end

      def anatomical_part_matches(anatomical_part_query, side, results_allowed)
        ids = anatomical_part_query.limit(results_allowed).pluck(:id)
        joined_matches('anatomical_parts', 'AnatomicalPart', side, ids, results_allowed)
      end

      def biological_relationship_matches(results_allowed)
        ids = biological_relationship_autocomplete.all.limit(results_allowed).pluck(:id)
        return [] if ids.empty?

        q = base_query
          .where(biological_relationship_id: ids)
          # Keep the relationship autocomplete's ranking, so that the
          # results cap keeps the best matches
          .order(Arel.sql(
            "array_position(ARRAY[#{ids.map(&:to_i).join(',')}], biological_associations.biological_relationship_id), biological_associations.id"
          ))
          .limit(results_allowed)

        apply_restriction(q).to_a
      end

      # @return [Array<Proc>]
      #   An ordered list of thunks, highest priority first. Each, when called with
      #   the number of results still wanted, lazily runs its own query and returns an
      #   Array<BiologicalAssociation>. Kept as thunks (rather than eagerly building/running
      #   every branch, as this used to) so `autocomplete` can stop pulling further branches,
      #   and cap how many candidate ids a branch even asks for, once enough results are found.
      def ordered_lazy_queries
        queries = [->(n) {
          q = autocomplete_exact_id
          q ? apply_restriction(q).to_a : []
        }]

        queries << ->(n) { otu_matches(:subject, n) }
        queries << ->(n) { otu_matches(:object, n) }

        %i{subject object}.each do |side|
          collection_object_autocomplete(side).base_queries
            .each { |q| queries << ->(n) { collection_object_matches(q, side, n) } }
        end

        %i{subject object}.each do |side|
          field_occurrence_autocomplete(side).base_queries
            .each { |q| queries << ->(n) { field_occurrence_matches(q, side, n) } }
        end

        queries << ->(n) { biological_relationship_matches(n) }

        %i{subject object}.each do |side|
          anatomical_part_autocomplete(side).updated_queries
            .each { |q| queries << ->(n) { anatomical_part_matches(q, side, n) } }
        end

        queries
      end

      # @return [Array]
      def autocomplete
        result = []
        ordered_lazy_queries.each do |q|
          remaining = limit - result.count
          break if remaining <= 0

          result += q.call(remaining)
          result.uniq!
        end

        result.first(limit)
      end

    end
  end
end
