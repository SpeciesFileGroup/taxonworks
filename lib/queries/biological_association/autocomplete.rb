module Queries
  module BiologicalAssociation
    class Autocomplete < Query::Autocomplete

      def initialize(string, project_id: nil)
        super
      end

      # @return [Queries::Otu::Autocomplete]
      def otu_autocomplete
        @otu_autocomplete ||= Queries::Otu::Autocomplete
          .new(query_string, project_id: project_id)
      end

      # @return [Queries::CollectionObject::Autocomplete]
      def collection_object_autocomplete
        @collection_object_autocomplete ||= Queries::CollectionObject::Autocomplete
          .new(query_string, project_id: project_id)
      end

      # @return [Queries::FieldOccurrence::Autocomplete]
      def field_occurrence_autocomplete
        @field_occurrence_autocomplete ||= Queries::FieldOccurrence::Autocomplete
          .new(query_string, project_id: project_id)
      end

      # @return [Queries::BiologicalRelationship::Autocomplete]
      def biological_relationship_autocomplete
        @biological_relationship_autocomplete ||= Queries::BiologicalRelationship::Autocomplete
          .new(query_string, project_id: project_id)
      end

      # @return [Queries::AnatomicalPart::Autocomplete]
      def anatomical_part_autocomplete
        @anatomical_part_autocomplete ||= Queries::AnatomicalPart::Autocomplete
          .new(query_string, project_id: project_id)
      end

      # @return [Array<BiologicalAssociation>]
      #   biological_associations where the subject or object (on `side`) is one of the
      #   related_klass records identified by `ids`
      def joined_matches(related_table_name, related_type, side, ids)
        return [] if ids.empty?

        foreign_key_column = "biological_association_#{side}_id"
        type_column = "biological_association_#{side}_type"

        base_query
          .joins(
            "JOIN #{related_table_name} ON biological_associations.#{foreign_key_column} = #{related_table_name}.id " \
            "AND biological_associations.#{type_column} = '#{related_type}'"
          )
          .where(related_table_name.to_sym => { id: ids })
          .to_a
      end

      def otu_matches(side, results_allowed)
        ids = otu_autocomplete.autocomplete_base.limit(results_allowed).pluck(:id)
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

        ::BiologicalAssociation
          .joins(:biological_relationship)
          .where(biological_relationship: { id: ids })
          .to_a
      end

      # @return [Array<Proc>]
      #   An ordered list of thunks, highest priority first. Each, when called with
      #   the number of results still wanted, lazily runs its own query and returns an
      #   Array<BiologicalAssociation>. Kept as thunks (rather than eagerly building/running
      #   every branch, as this used to) so `autocomplete` can stop pulling further branches,
      #   and cap how many candidate ids a branch even asks for, once enough results are found.
      def ordered_lazy_queries
        queries = [->(n) { [autocomplete_exact_id].compact.flat_map(&:to_a) }]

        queries << ->(n) { otu_matches(:subject, n) }
        queries << ->(n) { otu_matches(:object, n) }

        co = collection_object_autocomplete.base_queries
        co.each { |q| queries << ->(n) { collection_object_matches(q, :subject, n) } }
        co.each { |q| queries << ->(n) { collection_object_matches(q, :object, n) } }

        fo = field_occurrence_autocomplete.base_queries
        fo.each { |q| queries << ->(n) { field_occurrence_matches(q, :subject, n) } }
        fo.each { |q| queries << ->(n) { field_occurrence_matches(q, :object, n) } }

        queries << ->(n) { biological_relationship_matches(n) }

        ap = anatomical_part_autocomplete.updated_queries
        ap.each { |q| queries << ->(n) { anatomical_part_matches(q, :subject, n) } }
        ap.each { |q| queries << ->(n) { anatomical_part_matches(q, :object, n) } }

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
