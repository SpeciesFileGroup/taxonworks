class ColdpCreateDownloadJob < ApplicationJob
  queue_as :coldp_export

  def perform(otu, download)
    begin
      download.source_file_path = ::Export::Coldp.export(otu.id)
      download.save
    rescue => ex
      ExceptionNotifier.notify_exception(ex,
        data: { otu: otu&.id&.to_s, download: download&.id&.to_s }
      )
      raise
    end
  end
end
