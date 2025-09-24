module Queries
  module BiologicalAssociation
    class Autocomplete < Query::Autocomplete

      def initialize(string, project_id: nil)
        super
      end

      def updated_queries
        a = Queries::Otu::Autocomplete
          .new(query_string, project_id: project_id).autocomplete_base

        b = Queries::CollectionObject::Autocomplete
          .new(query_string, project_id: project_id).base_queries

        c = Queries::FieldOccurrence::Autocomplete
          .new(query_string, project_id: project_id).base_queries

        d = Queries::BiologicalRelationship::Autocomplete
          .new(query_string, project_id: project_id).all

        return [] if a.nil? && b.nil? && c.nil?

        updated_queries = []
        j = base_query
          .joins("JOIN otus ON biological_associations.biological_association_subject_id = otus.id AND biological_associations.biological_association_subject_type = 'Otu'")
          .where(otus: { id: a.limit(50).pluck(:id) })
        updated_queries << j

        j = base_query
          .joins("JOIN otus ON biological_associations.biological_association_object_id = otus.id AND biological_associations.biological_association_object_type = 'Otu'")
          .where(otus: { id: a.limit(50).pluck(:id) })
        updated_queries << j

        b.each do |q|
          j = ::BiologicalAssociation
            .joins("JOIN collection_objects ON biological_associations.biological_association_subject_id = collection_objects.id AND biological_associations.biological_association_subject_type = 'CollectionObject'")
            .where(collection_objects: { id: q.limit(50).pluck(:id) })
          updated_queries << j
        end

        b.each do |q|
          j = ::BiologicalAssociation
            .joins("JOIN collection_objects ON biological_associations.biological_association_object_id = collection_objects.id AND biological_associations.biological_association_object_type = 'CollectionObject'")
            .where(collection_objects: { id: q.limit(50).pluck(:id) })
          updated_queries << j
        end

        c.each do |q|
          j = ::BiologicalAssociation
            .joins("JOIN field_occurrences ON biological_associations.biological_association_subject_id = field_occurrences.id AND biological_associations.biological_association_subject_type = 'FieldOccurrence'")
            .where(field_occurrences: { id: q.limit(50).pluck(:id) })
          updated_queries << j
        end

        c.each do |q|
          j = ::BiologicalAssociation
            .joins("JOIN field_occurrences ON biological_associations.biological_association_object_id = field_occurrences.id AND biological_associations.biological_association_object_type = 'FieldOccurrence'")
            .where(field_occurrences: { id: q.limit(50).pluck(:id) })
          updated_queries << j
        end

        j = ::BiologicalAssociation
          .joins(:biological_relationship)
          .where(biological_relationship: { id: d.limit(50).pluck(:id) })
        updated_queries << j
      end

      # @return [Array]
      def autocomplete
        result = []
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 50
        end

        result[0..49]
      end

    end
  end
end
