# Helper methods for gathering and formatting duplicate predicate data.
# Claude provided > 50% of the code for this class.
module Tasks::DataAttributes::DuplicateDataAttributesHelper

  # Returns objects with duplicate predicates from a filter query result.
  # Groups data attributes by subject and predicate, returning only those
  # where the same predicate appears more than once on the same object.
  #
  # @param filter [Queries::Query::Filter] an instantiated filter
  # @param project_id [Integer] the current project id
  # @return [Hash] grouped data with objects and their duplicate data attributes
  def duplicate_predicate_data(filter, project_id)
    return { objects: [], total_objects_with_duplicates: 0 } if filter.nil?

    # Get all object IDs from the filter
    object_ids = filter.all.pluck(:id)
    object_type = filter.referenced_klass.name

    return { objects: [], total_objects_with_duplicates: 0 } if object_ids.empty?

    # Find data attributes for these objects where the predicate appears more than once
    duplicate_data = find_duplicate_predicate_attributes(object_ids, object_type, project_id)

    format_duplicate_data(duplicate_data, object_type, project_id)
  end

  private

  # Finds InternalAttributes where the same predicate appears multiple times on the same object.
  #
  # @param object_ids [Array<Integer>] IDs of objects to check
  # @param object_type [String] the polymorphic type (e.g., 'Otu', 'CollectionObject')
  # @param project_id [Integer] the current project id
  # @return [ActiveRecord::Relation] data attributes with duplicates
  def find_duplicate_predicate_attributes(object_ids, object_type, project_id)
    # Subquery to find subject/predicate combinations that appear more than once
    duplicate_combinations = InternalAttribute
      .where(
        attribute_subject_id: object_ids,
        attribute_subject_type: object_type,
        project_id: project_id
      )
      .group(:attribute_subject_id, :attribute_subject_type, :controlled_vocabulary_term_id)
      .having('COUNT(*) > 1')
      .select(:attribute_subject_id, :attribute_subject_type, :controlled_vocabulary_term_id)

    # Get all data attributes for those duplicate combinations
    InternalAttribute
      .joins("INNER JOIN (#{duplicate_combinations.to_sql}) AS dupes
              ON data_attributes.attribute_subject_id = dupes.attribute_subject_id
              AND data_attributes.attribute_subject_type = dupes.attribute_subject_type
              AND data_attributes.controlled_vocabulary_term_id = dupes.controlled_vocabulary_term_id")
      .where(project_id: project_id)
      .includes(:predicate, :creator, :updater)
      .order(:attribute_subject_id, :controlled_vocabulary_term_id, :value)
  end

  # Formats duplicate data for JSON response.
  #
  # @param data_attributes [ActiveRecord::Relation] the data attributes with duplicates
  # @param object_type [String] the polymorphic type
  # @param project_id [Integer] the current project id
  # @return [Hash] formatted data structure
  def format_duplicate_data(data_attributes, object_type, project_id)
    grouped = data_attributes.group_by(&:attribute_subject_id)

    objects = grouped.map do |object_id, attributes|
      object = object_type.constantize.find(object_id)

      # Group attributes by predicate to identify exact duplicates (same predicate + value)
      by_predicate = attributes.group_by(&:controlled_vocabulary_term_id)

      data_attributes_formatted = attributes.map do |da|
        predicate_group = by_predicate[da.controlled_vocabulary_term_id]
        exact_duplicates = predicate_group.select { |d| d.value == da.value }
        is_exact_duplicate = exact_duplicates.size > 1

        format_data_attribute(da, is_exact_duplicate)
      end

      {
        id: object.id,
        global_id: object.to_global_id.to_s,
        object_tag: object_tag(object),
        object_type: object_type,
        data_attributes: data_attributes_formatted
      }
    end

    {
      objects: objects,
      total_objects_with_duplicates: objects.size
    }
  end

  # Formats a single data attribute for the response.
  #
  # @param da [InternalAttribute] the data attribute
  # @param is_exact_duplicate [Boolean] whether this is an exact duplicate (same predicate AND value)
  # @return [Hash] formatted data attribute
  def format_data_attribute(da, is_exact_duplicate)
    predicate = da.predicate

    {
      id: da.id,
      predicate_id: da.controlled_vocabulary_term_id,
      predicate_name: predicate&.name,
      predicate_css_color: predicate&.css_color,
      value: da.value,
      creator_name: da.creator&.name,
      updater_name: da.updater&.name,
      updated_at: da.updated_at,
      is_exact_duplicate: is_exact_duplicate
    }
  end

end
