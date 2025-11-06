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

  validates :type, uniqueness: {
    scope: [:project_id],
    conditions: -> { unexpired },
    message: ->(record, data) {
      "Only one #{record.type} is allowed. Destroy the old version first."
    }
  }

  validate :has_eml_without_stubs

  def self.api_buildable?
    true
  end

  # @return [Download] the complete download to be served
  # Raises TaxonWorks::Error on error.
  def self.process_complete_download_request(project)
    # !! Note Current.user_id may not be set here !!
    download = Download.where(
      type: 'Download::DwcArchive::Complete', project_id: project.id
    ).first

    return nil if download.nil?

    if download.ready?
      max_age = project.complete_dwc_download_max_age # in days
      download_age = Time.current - download.created_at
      by_id = Current.user_id || project.complete_dwc_download_default_user_id
      if max_age && download_age.to_f / 1.day > max_age
        # Create a fresh download that will replace the existing one when
        # ready.
        Download::DwcArchive::PupalComplete.create(by: by_id) # don't raise if one already exists
      end

      download.increment!(:times_downloaded)
      return download
    else
      raise TaxonWorks::Error, 'The existing download is not ready yet'
    end
  end

  private
  def build
    project_params = { project_id: }
    record_scope = ::DwcOccurrence.where(project_params)
    eml_dataset, eml_additional_metadata = project.complete_dwc_eml_preferences
    predicates = project.complete_dwc_download_predicates || {}
    extensions = project.complete_dwc_download_extensions || []
    taxonworks_extensions = project.complete_dwc_download_internal_values || []

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
      project_id:
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
