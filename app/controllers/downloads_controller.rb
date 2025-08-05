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

  # DELETE /api/v1/downloads/1.json
  def api_destroy
    if !sessions_current_user.is_administrator? # user is from api token
      render json: { error: 'Only administrators can destroy downloads via the api' }, status: :unprocessable_entity
      return
    elsif !API_BUILDABLE_DOWNLOAD_TYPES.include?(@download.type)
      render json: { error: "Type '#{@download.type}' cannot be destroyed via api" }, status: :unprocessable_entity
      return
    end

    if @download.destroy
      render json: {id: @download.id_was, status: :destroyed}
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  # POST /api/v1/downloads/build?type=Download::DwcArchive::Complete
  def api_build
    if !sessions_current_user.is_administrator? # user is from api token
      render json: { error: 'Only administrators can start builds from the api' }, status: :unprocessable_entity
      return
    elsif !API_BUILDABLE_DOWNLOAD_TYPES.include?(params[:type])
      render json: { error: "Type '#{params[:type]}' is not allowed" }, status: :unprocessable_entity
      return
    end

    @download = Download.create(api_build_params)
    render '/downloads/api/v1/show'
  end

  def api_terminate
    @download.terminate # TODO, add method, or change to :destroy
    render '/downloads/api/v1/show'
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

  def api_build_params
    params.permit(:type, predicate_extensions: {
      collection_object_predicate_id: [],
      collecting_event_predicate_id: []
    })
  end
end
