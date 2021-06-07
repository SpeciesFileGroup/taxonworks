class Tasks::Dwc::DashboardController < ApplicationController
  include TaskControllerConfiguration

  # DWC_TASK
  def index
  end

  # rails jobs:work
  def generate_download
    a = DwcOccurrence.where(project_id: sessions_current_project_id).all
    download = ::Export::Dwca.download_async(a, request.url)
    redirect_to file_download_path(download)
  end

end
