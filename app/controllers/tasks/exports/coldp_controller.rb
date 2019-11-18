class Tasks::Exports::ColdpController < ApplicationController
  include TaskControllerConfiguration

  def index
  end

  def download
    @otu = Otu.where(project_id: sessions_current_project_id).find(params.require(:otu_id))
    download = ::Export::Coldp.download_async(@otu, request.url)

    redirect_to download_file_download_path(download)
  end
end
