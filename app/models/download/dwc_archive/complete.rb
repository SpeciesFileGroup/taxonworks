# Only one per project.  Includes the complete current contents of DwCOccurrences.
class Download::DwcArchive::Complete < Download::DwcArchive
  include Shared::CompleteDownload

  attribute :name, default: -> { "dwc-a_complete_#{DateTime.now}.zip" }
  attribute :description, default: 'A Darwin Core archive of the complete TaxonWorks DwcOccurrence table'
  attribute :filename, default: -> { "dwc-a_complete_#{DateTime.now}.zip" }
  attribute :request, default: -> { '/api/v1/downloads/dwc_archive_complete' }

  validates :type, uniqueness: {
    scope: [:project_id],
    conditions: -> { unexpired },
    message: ->(record, data) {
      "Only one #{record.type} is allowed. Destroy the old version first."
    }
  }

  validate :has_eml_without_stubs

  def self.complete_download_access_authorized?(project, _params)
    project.complete_dwc_download_is_public?
  end

  def self.complete_download_max_age(project, _params)
    project.complete_dwc_download_max_age
  end

  def self.complete_download_default_user_id(project, _params)
    project.complete_dwc_download_default_user_id
  end

  private

  # Builds the complete DwC-A export by enqueuing a job.
  #
  # Constructs the export parameters from project preferences and enqueues
  # DwcaCreateDownloadJob to generate the archive.
  def build
    project_params = { project_id: }
    record_scope = ::DwcOccurrence.where(project_params)
    eml_dataset, eml_additional_metadata = project.complete_dwc_eml_preferences
    predicates = project.complete_dwc_download_predicates || {}
    extensions = project.complete_dwc_download_extensions || []
    taxonworks_extensions = project.complete_dwc_download_internal_values || []
    by_id = Current.user_id || project.complete_dwc_download_default_user_id

    biological_associations_scope = extensions.include?('resource_relationships') ?
      {
        core_params: project_params, # all dwc_occurrences for this project
        collection_objects_query: ::Queries::BiologicalAssociation::Filter.new(
          collection_object_query: ::Queries::CollectionObject::Filter.new(
            dwc_occurrence_query: project_params
          ).params
        ).all.to_sql
      } : nil
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
      predicate_extensions: normalized_predicate_extensions(predicates),
      taxonworks_extensions:,
      project_id:,
      user_id: by_id
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

    # Guarantees that a GBIF call (every 7 days) will occur after max_age and
    # before the existing download expires.
    self.expires = Time.zone.now + max_age.days + 7.day + 1.day
  end

  def self.project_api_access_token_destroyed
    # May not be necessary if the download doesn't include media extension, but we're doing it anyway.
    Download::DwcArchive::Complete.destroy_all
  end
end
