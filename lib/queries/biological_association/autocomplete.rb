module Queries
  module BiologicalAssociation
    class Autocomplete < Query::Autocomplete

      def initialize(string, project_id: nil, restrict_to: nil)
        super(string, project_id:, restrict_to:)
      end

      # @return [ActiveRecord::Relation, nil]
      #   the klass records that are the `side` (:subject or :object) of a
      #   restrict_to biological_association, nil when there is no restriction
      def side_restriction(klass, side)
        return nil if restrict_to.nil?

        klass.where(
          id: apply_restriction(::BiologicalAssociation.all)
            .where("biological_association_#{side}_type": klass.base_class.name)
            .select("biological_association_#{side}_id")
        )
      end

      # @return [Query::Autocomplete]
      #   an autocomplete_klass autocomplete restricted to klass records that
      #   can be on `side` of a restrict_to biological_association, so that
      #   records that can't match don't use up its candidate limits
      def side_autocomplete(autocomplete_klass, klass, side)
        @side_autocompletes ||= {}
        @side_autocompletes[[autocomplete_klass, side]] ||= autocomplete_klass
          .new(query_string, project_id:, restrict_to: side_restriction(klass, side))
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
      #   related_klass records identified by `ids`
      def joined_matches(related_table_name, related_type, side, ids)
        return [] if ids.empty?

        foreign_key_column = "biological_association_#{side}_id"
        type_column = "biological_association_#{side}_type"

        q = base_query
          .joins(
            "JOIN #{related_table_name} ON biological_associations.#{foreign_key_column} = #{related_table_name}.id " \
            "AND biological_associations.#{type_column} = '#{related_type}'"
          )
          .where(related_table_name.to_sym => { id: ids })

        apply_restriction(q).to_a
      end

      def otu_matches(side, results_allowed)
        ids = otu_autocomplete(side).autocomplete_base.limit(results_allowed).pluck(:id)
        joined_matches('otus', 'Otu', side, ids)
      end

      def collection_object_matches(collection_object_query, side, results_allowed)
        ids = collection_object_query.limit(results_allowed).pluck(:id)
        joined_matches('collection_objects', 'CollectionObject', side, ids)
      end

      def field_occurrence_matches(field_occurrence_query, side, results_allowed)
        ids = field_occurrence_query.limit(results_allowed).pluck(:id)
        joined_matches('field_occurrences', 'FieldOccurrence', side, ids)
      end

      def anatomical_part_matches(anatomical_part_query, side, results_allowed)
        ids = anatomical_part_query.limit(results_allowed).pluck(:id)
        joined_matches('anatomical_parts', 'AnatomicalPart', side, ids)
      end

      def biological_relationship_matches(results_allowed)
        ids = biological_relationship_autocomplete.all.limit(results_allowed).pluck(:id)
        return [] if ids.empty?

        q = ::BiologicalAssociation
          .joins(:biological_relationship)
          .where(biological_relationship: { id: ids })

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
          remaining = 50 - result.count
          break if remaining <= 0

          result += q.call(remaining)
          result.uniq!
        end

        result[0..49]
      end

    end
  end
end
