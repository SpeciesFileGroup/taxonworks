class DownloadsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_download, only: [:show, :download_file, :destroy, :update, :file, :edit]
  before_action :set_download_api, only: [:api_file, :api_show, :api_destroy]

  after_action -> { set_pagination_headers(:downloads) }, only: [:api_index], if: :json_request?

  skip_forgery_protection only: [:api_build, :api_destroy]

  # GET /downloads
  # GET /downloads.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = Download.unscoped.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @downloads = Queries::Download::Filter.new(params)
          .all
          .page(params[:page])
          .per(params[:per])
      }
    end
  end

  # GET /downloads/1
  def show
  end

  # GET /downloads/1/edit
  def edit
  end

  # DELETE /downloads/1
  # DELETE /downloads/1.json
  def destroy
    @download.destroy
    respond_to do |format|
      if @download.destroyed?
        format.html { destroy_redirect @download, notice: 'Download was successfully destroyed.' }
        format.json { head :no_content}
      else
        format.html { destroy_redirect @download, notice: 'Download was not destroyed, ' + @download.errors.full_messages.join('; ') }
        format.json { render json: @download.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /downloads/1
  # PATCH /downloads/1.json
  def update
    respond_to do |format|
      if @download.update(download_params)
        format.html { redirect_to @download.metamorphosize, notice: 'Download was successfully updated.' }
        format.json { render :show, location: @download.metamorphosize }
      else
        format.html { render action: 'edit' }
        format.json { render json: @download.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /downloads/list
  # GET /downloads/list.json
  def list
    # has a default scope
    @downloads = Download.unscoped.where(project_id: sessions_current_project_id).order(:id).page(params[:page]).per(params[:per])
  end

  # GET /downloads/1/file
  def file
    if @download.ready?
      @download.increment!(:times_downloaded)
      response.headers["Content-Length"] = File.size(@download.file_path).to_s
      send_file @download.file_path
    else
      redirect_to download_url
    end
  end

  def api_index
    # If default scope is removed return here
    @downloads = Download.where(project_id: sessions_current_project_id)
      .order('downloads.id').page(params[:page]).per(params[:per])
    render '/downloads/api/v1/index'
  end

  # GET /api/v1/downloads/123/file.json
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

  # POST /api/v1/downloads/api_dwc_archive_complete?project_token=<>
  def api_dwc_archive_complete
    project = Project.find(sessions_current_project_id)

    if !project.dwc_download_is_public?
      render json: { success: false }
      return
    end

    complete_download_type = 'Download::DwcArchive::Complete'
    download = Download.where(type: complete_download_type).first
    if download
      if download.ready?
        max_age = project.complete_dwc_download_max_age
        download_age = Time.current - download.created_at
        if download_age.to_f / 1.day > max_age
          # Delete the old download and create a new one. We may want to adjust
          # this later, but if it's just (mostly) GBIF doing regularly scheduled
          # downloads and us scheduling the creates, this should be fine.
          download.destroy
          Download::DwcArchive::Complete.create!
          render json: { status: 'A new download is being created'}
          return
        else # Success!
          download.increment!(:times_downloaded)
          send_file download.file_path
        end
      else
        render json: { status: 'The existing download is not ready yet' }
      end

      return
    end

    # Complete project download doesn't exist yet, spin one up.
    # *All* options for complete downloads are determined from project
    # preferences, not from public request via api.
    # !! Publicly explodes if EML prefs contain 'STUB' text.
    Download::DwcArchive::Complete.create!
    render json: { status: 'A download is being created' }
  end

  private

  def set_download
    # Why .unscoped ?
    @download = Download.unscoped.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def set_download_api
    @download = Download.unscoped.where(is_public: true, project_id: sessions_current_project_id).find(params[:id])
  end

  def download_params
    params.require(:download).permit(:is_public, :name, :expires )
  end

end
