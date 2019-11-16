class DownloadsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_download, only: [:show, :download_file, :destroy]

  # GET /downloads
  # GET /downloads.json
  def index
    @recent_objects = Download.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
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

  # GET /downloads/list
  # GET /downloads/list.json
  def list
    @downloads = Download.order(:id).page(params[:page]).per(params[:per])
  end

  # GET /downloads/1/download_file
  def download_file
    if @download.ready?
      @download.increment!(:times_downloaded)
      send_file @download.file_path
    else
      redirect_to download_url
    end
  end

  private

  def set_download
    @download = Download.unscoped.find(params[:id])
  end

  def download_params
    params.require(:download).permit()
  end
end
