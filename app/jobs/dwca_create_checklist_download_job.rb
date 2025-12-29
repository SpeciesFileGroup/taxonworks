class DwcaCreateChecklistDownloadJob < ApplicationJob
  queue_as :dwca_export

  # @param download_id [Integer] Download record ID
  # @param core_otu_scope_params [Hash] OTU query parameters
  # @param extensions [Array<Symbol>] Extensions to include
  # @param accepted_name_mode [String] How to handle unaccepted names ('replace_with_accepted_name' or 'accepted_name_usage_id')
  # @param project_id [Integer] Project ID
  def perform(download_id, core_otu_scope_params: {}, extensions: [], accepted_name_mode: 'replace_with_accepted_name', project_id: nil)
    # Raise and fail without notifying if our download was deleted before we run.
    download = Download.find(download_id)
    # Filter queries will fail in unexpected ways without project_id set as expected!
    raise TaxonWorks::Error, "Project_id not set! #{core_otu_scope_params}" if project_id.nil?
    Current.project_id = project_id

    begin
      begin
        d = ::Export::Dwca::ChecklistData.new(core_otu_scope_params:, extensions:, accepted_name_mode:)
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
