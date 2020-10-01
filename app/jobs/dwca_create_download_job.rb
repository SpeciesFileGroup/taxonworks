class DwcaCreateDownloadJob < ApplicationJob
  queue_as :dwca_export

  def perform(record_scope, download)
    begin
      download.source_file_path = ::Export::Dwca.get_archive(record_scope)
      download.save
    rescue => ex
      ExceptionNotifier.notify_exception(ex, data: {  download: download&.id&.to_s } ) # otu: otu&.id&.to_s,
      raise
    end
  end
end
