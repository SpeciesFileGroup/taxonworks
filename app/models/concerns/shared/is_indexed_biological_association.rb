# Shared code for BiologicalAssociation to maintain the
# biological_association_index table.
module Shared::IsIndexedBiologicalAssociation
  extend ActiveSupport::Concern

  included do
    delegate :persisted?, to: :biological_association_index, prefix: :biological_association_index, allow_nil: true

    # @return Boolean, nil
    #   when true prevents automatic index from being created
    attr_accessor :no_biological_association_index

    has_one :biological_association_index, foreign_key: :biological_association_id, dependent: :destroy, inverse_of: :biological_association

    after_save :set_biological_association_index, unless: -> { no_biological_association_index }

    scope :ba_indexed, -> { joins(:biological_association_index) }
    scope :ba_not_indexed, -> { where.missing(:biological_association_index) }
  end

  # @return [BiologicalAssociationsIndex]
  #   !! always touches the database
  def set_biological_association_index
    retried = false
    begin
      if biological_association_index_persisted?
        biological_association_index.update_columns(
          biological_association_index_attributes.merge(
            updated_at: Time.zone.now)
        )
      else
        create_biological_association_index!(biological_association_index_attributes)
      end
    rescue ActiveRecord::ActiveRecordError
      unless retried
        retried = true
        biological_association_index&.reload
        retry
      else
        raise
      end
    end
    biological_association_index
  end

  # @return Hash
  #   of field: value
  #
  # !! This is expensive, it recomputes values for every field.
  def biological_association_index_attributes
    {
      biological_association_id: id,
      biological_relationship_id: biological_relationship_id,
      project_id: project_id,
      created_by_id: created_by_id,
      updated_by_id: updated_by_id,

      # Subject fields
      subject_id: biological_association_subject_id,
      subject_type: biological_association_subject_type,
      subject_uuid: biological_association_subject_uuid,
      subject_label: biological_association_subject_label,
      subject_order: biological_association_subject_taxonomy_field('order'),
      subject_family: biological_association_subject_taxonomy_field('family'),
      subject_genus: biological_association_subject_taxonomy_field('genus'),
      subject_properties: biological_association_subject_properties,

      # Relationship fields
      biological_relationship_uri: biological_relationship_uri,
      relationship_name: biological_relationship.name,
      relationship_inverted_name: biological_relationship.inverted_name,

      # Object fields
      object_id: biological_association_object_id,
      object_type: biological_association_object_type,
      object_uuid: biological_association_object_uuid,
      object_label: biological_association_object_label,
      object_order: biological_association_object_taxonomy_field('order'),
      object_family: biological_association_object_taxonomy_field('family'),
      object_genus: biological_association_object_taxonomy_field('genus'),
      object_properties: biological_association_object_properties,

      # Citations and metadata
      citations: biological_association_citations,
      citation_year: biological_association_citation_year,
      established_date: dwc_relationship_established_date(false),
      remarks: biological_association_remarks
    }
  end

  # @return [BiologicalAssociationsIndex]
  #   does not rebuild if already built
  def get_biological_association_index
    if biological_association_index_persisted?
      biological_association_index
    else
      set_biological_association_index
    end
  end

  private

  def biological_association_subject_uuid
    case biological_association_subject.class.base_class.name
    when 'Otu', 'CollectionObject', 'FieldOccurrence'
      biological_association_subject.uuid
    end
  end

  def biological_association_object_uuid
    case biological_association_object.class.base_class.name
    when 'Otu', 'CollectionObject', 'FieldOccurrence'
      biological_association_object.uuid
    end
  end

  def biological_association_subject_label
    ApplicationController.helpers.label_for(biological_association_subject)
  end

  def biological_association_object_label
    ApplicationController.helpers.label_for(biological_association_object)
  end

  def biological_association_subject_taxonomy_field(rank)
    [biological_association_subject.taxonomy[rank]].flatten.compact.join(' ').presence
  end

  def biological_association_object_taxonomy_field(rank)
    [biological_association_object.taxonomy[rank]].flatten.compact.join(' ').presence
  end

  def biological_association_subject_properties
    subject_biological_properties.pluck(:name).join(Shared::IsDwcOccurrence::DWC_DELIMITER).presence
  end

  def biological_association_object_properties
    object_biological_properties.pluck(:name).join(Shared::IsDwcOccurrence::DWC_DELIMITER).presence
  end

  def biological_relationship_uri
    biological_relationship.uris.first&.cached
  end

  def biological_association_citations
    ApplicationController.helpers.short_sources_tag(sources)
  end

  def biological_association_citation_year
    ApplicationController.helpers.short_sources_year_tag(sources)
  end

  def biological_association_remarks
    Utilities::Strings.sanitize_for_csv(notes.collect { |n| n.text }.join(Shared::IsDwcOccurrence::DWC_DELIMITER)).presence
  end

end
