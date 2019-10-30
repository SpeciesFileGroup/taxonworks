class ColdpCreateDownloadJob < ApplicationJob
  queue_as :coldp_export

  def perform(otu, download)
    download.source_file_path = ::Export::Coldp.export(otu.id)
    download.save
  end
end
