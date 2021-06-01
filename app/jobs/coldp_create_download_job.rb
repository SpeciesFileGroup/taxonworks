class ColdpCreateDownloadJob < ApplicationJob
  queue_as :coldp_export

  def max_run_time
    1.hour
  end

  def max_attempts
    2
  end

  def perform(otu, download, prefer_unlabelled_otus: false)
    begin
      download.source_file_path = ::Export::Coldp.export(otu.id, prefer_unlabelled_otus: prefer_unlabelled_otus)
      download.save
    rescue => ex
      ExceptionNotifier.notify_exception(ex,
        data: { otu: otu&.id&.to_s, download: download&.id&.to_s }
      )
      raise
    end
  end
end
