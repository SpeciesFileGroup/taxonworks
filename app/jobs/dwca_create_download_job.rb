class DwcaCreateDownloadJob < ApplicationJob
  queue_as :dwca_export

  # @param download [a Download instance]
  # @param core_scope [String, ActiveRecord::Relation]
  #   String of SQL generated from the scope
  #   SQL must  return a list of DwcOccurrence records
  # take a download, and a list of scopes, and save the result to the download, that's all
  def perform(download_id, core_scope: nil, extension_scopes: {biological_associations: nil, media: nil}, predicate_extensions: {}, taxonworks_extensions: [])
    # Raise and fail without notifying if our download was deleted before we run.
    download = Download.find(download_id)

    begin
      begin
        d = ::Export::Dwca::Data.new(core_scope:, predicate_extensions:, extension_scopes:, taxonworks_extensions:)
        d.package_download(download)
        d
      ensure
        d.cleanup
      end
    rescue => ex
      ExceptionNotifier.notify_exception(ex, data: { download: download&.id&.to_s } )
      raise
    end
  end

end
