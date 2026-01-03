class DwcaCreateDownloadJob < ApplicationJob
  queue_as :dwca_export

  # Creates a DwC-A export and packages it into a Download.
  #
  # @param download_id [Integer]
  #   The ID of the Download instance to package the export into.
  # @param core_scope [String, ActiveRecord::Relation]
  #   Required. DwcOccurrence scope (SQL string or ActiveRecord::Relation).
  # @param extension_scopes [Hash]
  #   Optional extensions to include:
  #   - :biological_associations [Hash] with keys :core_params and
  #     :collection_objects_query
  #   - :media [Hash] with keys :collection_objects (query string) and
  #     :field_occurrences (query string)
  # @param predicate_extensions [Hash]
  #   Predicate IDs to include:
  #   - :collection_object_predicate_id [Array<Integer>]
  #   - :collecting_event_predicate_id [Array<Integer>]
  # @param eml_data [Hash]
  #   EML metadata configuration:
  #   - :dataset [String] XML string for dataset metadata
  #   - :additional_metadata [String] XML string for additional metadata
  # @param taxonworks_extensions [Array<Symbol>]
  #   TaxonWorks-specific fields to export
  #   (e.g., [:otu_name, :elevation_precision]).
  # @param project_id [Integer]
  #   Required. The project ID for scoping queries.
  def perform(download_id, core_scope: nil, extension_scopes: {biological_associations: nil, media: nil}, predicate_extensions: {}, eml_data: {dataset: nil, additional_metadata: nil}, taxonworks_extensions: [],
  project_id: nil)
    # Raise and fail without notifying if our download was deleted before we run.
    download = Download.find(download_id)
    # Filter queries will fail in unexpected ways without project_id set as
    # expected!
    raise TaxonWorks::Error, "Project_id not set! #{core_scope}" if project_id.nil?
    Current.project_id = project_id

    begin
      begin
        d = ::Export::Dwca::Occurrence::Data.new(core_scope:, predicate_extensions:, extension_scopes:, taxonworks_extensions:, eml_data:)
        d.package_download(download)
      ensure
        d&.cleanup
      end
    rescue => ex
      ExceptionNotifier.notify_exception(ex, data: { download: download&.id&.to_s } )
      raise
    end

    # The zipfile has been moved to its download location, but the db download
    # could have been deleted at any time during our processing (in a
    # different thread), so see if we need to do some cleanup.
    if !Download.find_by(id: download.id)
      download.delete_file # doesn't raise if file is already gone
      raise TaxonWorks::Error, "Complete download build aborted: download '#{download.id}' no longer exists."
      return
    end
  end

end
