class Tasks::Exports::TaxonworksProjectController < ApplicationController
  include TaskControllerConfiguration

  def index
  end

  def sql_download
    download = ::Export::Project::Sql.download(sessions_current_project)
    redirect_to download_path(download)
  end

  def csv_download
    download = ::Export::Project::Csv.download(sessions_current_project)
    redirect_to download_path(download)
  end

end
