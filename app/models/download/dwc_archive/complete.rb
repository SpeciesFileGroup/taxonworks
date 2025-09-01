# Only one per project.  Includes the complete current contents of DwCOccurrences.
class Download::DwcArchive::Complete < Download::DwcArchive
  # Default values
  attribute :name, default: -> { "dwc-a_complete_#{DateTime.now}.zip" }
  attribute :description, default: 'A Darwin Core archive of the complete TaxonWorks DwcOccurrence table'
  attribute :filename, default: -> { "dwc-a_complete_#{DateTime.now}.zip" }
  attribute :expires, default: -> { 1.month.from_now }
  attribute :request, default: -> { '/api/v1/downloads/api_dwc_archive_complete' }
  attribute :is_public, default: -> { 1 }

  after_save :build, unless: :ready? # prevent infinite loop callbacks

  validates_uniqueness_of :type, scope: [:project_id], message: 'Only one Download::DwcArchive::Complete is allowed. Destroy the old version first.'

  def self.api_buildable?
    true
  end

  def build
    record_scope = ::DwcOccurrence.where(project_id: project_id)
    eml_dataset, eml_additional_metadata = project.eml_preferences
    ::DwcaCreateDownloadJob.perform_later(
      id,
      core_scope: record_scope.to_sql,
      eml_data: { dataset: eml_dataset, additional_metadata: eml_additional_metadata }
    )
  end

  private

  # predicate_extensions may have been initialized from query parameters with
  # string keys and string values.
  def normalized_predicate_extensions
    return {} if !predicate_extensions&.is_a?(Hash)

    predicate_extensions.inject({}) do |h, (k, v)|
      h[k.to_sym] = v.map(&:to_i)
      h
    end
  end

end
