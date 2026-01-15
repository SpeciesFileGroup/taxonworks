class DwcaCreateDownloadJob < ApplicationJob
  queue_as :dwca_export

  def max_attempts
    1
  end

  # @param download [a Download instance]
  # @param core_scope [String, ActiveRecord::Relation]
  #   String of SQL generated from the scope
  #   SQL must  return a list of DwcOccurrence records
  # take a download, and a list of scopes, and save the result to the download, that's all
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
        d = ::Export::Dwca::Data.new(core_scope:, predicate_extensions:, extension_scopes:, taxonworks_extensions:, eml_data:)
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
