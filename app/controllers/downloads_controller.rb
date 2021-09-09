class DownloadsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_download, only: [:show, :download_file, :destroy, :update, :file, :api_show]
  before_action :set_download_api, only: [:api_file, :api_show]

  after_action -> { set_pagination_headers(:downloads) }, only: [:api_index], if: :json_request?

  # GET /downloads
  # GET /downloads.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = Download.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @downloads = Queries::Download::Filter.new(filter_params)
          .all
          .where(project_id: sessions_current_project_id)
          .page(params[:page])
          .per(params[:per] || 20)
      }
    end
  end

  # GET /downloads/1
  def show
  end

  # DELETE /downloads/1
  # DELETE /downloads/1.json
  def destroy
    @download.destroy
    respond_to do |format|
      format.html { redirect_to downloads_url, notice: 'Download was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # PATCH /downloads/1
  # PATCH /downloads/1.json
  def update
    @download.update(download_params)
    render action: :show
  end

  # GET /downloads/list
  # GET /downloads/list.json
  def list
    @downloads = Download.where(project_id: sessions_current_project_id).order(:id).page(params[:page]).per(params[:per])
  end

  # GET /downloads/1/file
  def file
    if @download.ready?
      @download.increment!(:times_downloaded)
      send_file @download.file_path
    else
      redirect_to download_url
    end
  end

  def api_index
    @downloads = Download.where(is_public: true, project_id: sessions_current_project_id)
      .order('downloads.id').page(params[:page]).per(params[:per])
    render '/downloads/api/v1/index'
  end

  def api_file
    if @download.ready?
      @download.increment!(:times_downloaded)
      send_file @download.file_path
    else
      render json: { success: false }
    end
  end

  def api_show
    render '/downloads/api/v1/show'
  end

  private

  def filter_params
    params.permit(:download_type)
  end

  def set_download
    @download = Download.unscoped.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def set_download_api
    @download = Download.unscoped.where(is_public: true, project_id: sessions_current_project_id).find(params[:id])
  end

  def download_params
    params.require(:download).permit(:is_public)
  end
end
