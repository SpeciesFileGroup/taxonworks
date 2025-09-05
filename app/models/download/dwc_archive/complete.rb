# Only one per project.  Includes the complete current contents of DwCOccurrences.
class Download::DwcArchive::Complete < Download::DwcArchive
  # Default values
  attribute :name, default: -> { "dwc-a_complete_#{DateTime.now}.zip" }
  attribute :description, default: 'A Darwin Core archive of the complete TaxonWorks DwcOccurrence table'
  attribute :filename, default: -> { "dwc-a_complete_#{DateTime.now}.zip" }
  attribute :expires, default: -> { 1.month.from_now }
  attribute :request, default: -> { '/api/v1/downloads/api_dwc_archive_complete' }
  attribute :is_public, default: -> { 1 }

  before_save :sync_expires_with_preferences
  after_save :build, unless: :ready? # prevent infinite loop callbacks

  validates_uniqueness_of :type, scope: [:project_id], message: 'Only one Download::DwcArchive::Complete is allowed. Destroy the old version first.'

  validate :has_eml_without_stubs

  def self.api_buildable?
    true
  end

  private

  def build
    project_params = { project_id: }
    record_scope = ::DwcOccurrence.where(project_params)
    eml_dataset, eml_additional_metadata = project.complete_dwc_eml_preferences
    predicates = project.complete_dwc_download_predicates || []
    extensions = project.complete_dwc_download_extensions || []
    # TODO adjust these on merge with media extensions pr and TEST media
    biological_associations_scope = extensions.include?('resource_relationships') ?
      ::Queries::BiologicalAssociation::Filter.new(
        collection_object_query: ::Queries::CollectionObject::Filter.new(
          dwc_occurrence_query: project_params
        ).params
      ).all.to_sql : nil
    media_scope = extensions.include?('media') ?
      {
        collection_objects: ::Queries::CollectionObject::Filter.new(
          dwc_occurrence_query: project_params
        ).all.to_sql,

        field_occurrences: ::Queries::FieldOccurrence::Filter.new(
          dwc_occurrence_query: project_params
        ).all.to_sql
      } : nil

    ::DwcaCreateDownloadJob.perform_later(
      id,
      core_scope: record_scope.to_sql,
      eml_data: {
        dataset: eml_dataset,
        additional_metadata: eml_additional_metadata
      },
      extension_scopes: {
        biological_associations: biological_associations_scope,
        media: media_scope
      },
      predicate_extensions: normalized_predicate_extensions(predicates)
    )
  end

  def has_eml_without_stubs
    eml_dataset, eml_additional_metadata = project.complete_dwc_eml_preferences
    # dataset has required fields for eml GBIF validation, additional metadata
    # does not.

    # TODO: require the required dataset EML fields that GBIF requires.
    if eml_dataset.nil? || eml_dataset.empty?
      errors.add(:base, 'Non-empty dataset xml is required')
    end

    if eml_dataset.include?('STUB')
      errors.add(:base, "EML dataset cannot contain 'STUB'")
    end

    if eml_additional_metadata&.include?('STUB')
      errors.add(:base, "EML additional metadata cannot contain 'STUB'")
    end
  end

  # predicate_extensions may have been initialized from query parameters with
  # string keys and string values.
  def normalized_predicate_extensions(predicates)
    return {} if !predicates&.is_a?(Hash)

    predicates.inject({}) do |h, (k, v)|
      h[k.to_sym] = v.map(&:to_i)
      h
    end
  end

  def sync_expires_with_preferences
    max_age = project.complete_dwc_download_max_age
    return if max_age.nil?

    self.expires = Time.zone.now + max_age.days + 1.day
  end
end
