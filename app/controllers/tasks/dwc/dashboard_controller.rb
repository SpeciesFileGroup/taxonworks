class Tasks::Dwc::DashboardController < ApplicationController
  include TaskControllerConfiguration

  # DWC_TASK
  def index
  end

  def generate_download
    download = ::Export::BasicNomenclature.download_async(@taxon_name, request.url)
    redirect_to file_download_path(download)
  end

end
