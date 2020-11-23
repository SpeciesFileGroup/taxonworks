class Tasks::Exports::TaxonworksProjectController < ApplicationController
  include TaskControllerConfiguration

  def index
  end

  def download
    download = ::Export::Project.download(sessions_current_project)
    redirect_to download_path(download)
  end

end
