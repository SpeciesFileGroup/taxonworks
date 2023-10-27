class Tasks::Projects::DataController < ApplicationController
  include TaskControllerConfiguration

  # GET task/projects/data
  def index
    @project = Project.find(sessions_current_project_id)
  end

  def sql_download
    download = ::Export::ProjectData::Sql.download_async(sessions_current_project)
    redirect_to download_path(download)
  end

  def tsv_download
    download = ::Export::ProjectData::Tsv.download_async(sessions_current_project)
    redirect_to file_download_path(download)
  end

end
