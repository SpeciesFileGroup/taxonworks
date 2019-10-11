class Tasks::Exports::ColdpController < ApplicationController
  include TaskControllerConfiguration

  def index
  end

  def download
    @otu = Otu.where(project_id: sessions_current_project_id).find(params.require(:otu_id))
    download = ::Export::Coldp.download(@otu, request.url)
    download.update_attribute(:times_downloaded, 1)

    send_data download.file,
      type: 'zip',
      filename: download.filename
  end
end
