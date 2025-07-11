class Tasks::Projects::DataController < ApplicationController
  include TaskControllerConfiguration

  # GET task/projects/data
  def index
    allowed_types = ['Download::ProjectDump::Tsv', 'Download::ProjectDump::Sql']

    @project = Project.find(sessions_current_project_id)
    @recent_objects = Download.where(project_id: sessions_current_project_id, type: allowed_types)
      .order(created_at: :desc)
      .limit(10)
  end

  def sql_download
    custom_password = params[:custom_password].presence
    download = ::Export::ProjectData::Sql.download_async(sessions_current_project, custom_password: custom_password)
    redirect_to download_path(download)
  end

  def tsv_download
    download = ::Export::ProjectData::Tsv.download_async(sessions_current_project)
    redirect_to file_download_path(download)
  end

end
