class DwcaCreateDownloadJob < ApplicationJob
  queue_as :dwca_export

  # @param core_scope [String, ActiveRecord::Relation]
  #   String of SQL generated from the scope
  #   SQL must  return a list of DwcOccurrence records
  # take a download, and a list of scopes, and save the result to the download, that's all
  # @return
  # # TODO: handle extension scopes
  def perform(download, core_scope: nil, extension_scopes: {biological_associations: nil}, predicate_extension_params: nil)
    begin
      begin
        d = ::Export::Dwca::Data.new(core_scope: core_scope, predicate_extension_params: predicate_extension_params)
        d.package_download(download)
        d
      ensure
        d.cleanup
      end
    rescue => ex
      ExceptionNotifier.notify_exception(ex, data: {  download: download&.id&.to_s } ) # otu: otu&.id&.to_s,
      raise
    end
  end

end
