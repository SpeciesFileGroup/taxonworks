class BibtexCreateDownloadJob < ApplicationJob
  queue_as :bibtex_export

  def perform(params, download)
    begin
      download.source_file_path = ::Export::Bibtex.export(params)
      download.save
    rescue => ex
      ExceptionNotifier.notify_exception(ex,
        data: { bibtex: 'params', download: download&.id&.to_s }
      )
      raise
    end
  end
end
