class DownloadsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  # Routed via /api/v1/downloads/:download_type — keys must match the symbol
  # passed in the URL.
  COMPLETE_DOWNLOAD_TYPES = {
    'dwc_archive_complete' => 'Download::DwcArchive::Complete',
    'coldp_complete' => 'Download::Coldp::Complete'
  }.freeze

  before_action :set_download, only: [:show, :download_file, :destroy, :update, :file, :edit]
  before_action :set_download_api, only: [:api_file, :api_show, :api_destroy]

  before_action :resolve_complete_download_class, only: [:api_complete]
  before_action :authorize_complete_download_access, only: [:api_complete]

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
        format.json { render json: @download.errors, status: :unprocessable_content }
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
        format.json { render json: @download.errors, status: :unprocessable_content }
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
      response.headers['Content-Length'] = File.size(@download.file_path).to_s
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

  # GET /api/v1/downloads/:download_type?project_token=<>[&...]
  def api_complete
    project = Project.find(sessions_current_project_id)

    begin
      if download = @complete_download_class.process_complete_download_request(project, complete_download_params)
        send_file download.file_path
        return
      end
    rescue TaxonWorks::Error => e
      render json: { status: e.to_s }, status: :unprocessable_content
      return
    end

    @complete_download_class.create_complete_download(project, complete_download_params)
    render json: { status: 'A download is being created' }, status: :unprocessable_content
  end

  private

  def resolve_complete_download_class
    type_name = COMPLETE_DOWNLOAD_TYPES[params[:download_type]]
    @complete_download_class = type_name&.safe_constantize

    return if @complete_download_class

    render json: { error: "Unknown download type: #{params[:download_type]}" }, status: :not_found
  end

  def authorize_complete_download_access
    project = Project.find(sessions_current_project_id)

    missing = @complete_download_class.complete_download_required_params.reject { |k| params[k].present? }
    if missing.any?
      render json: { error: "Missing required params: #{missing.join(', ')}" }, status: :unprocessable_content
      return
    end

    return if project.api_access_token.present? &&
              @complete_download_class.complete_download_access_authorized?(project, complete_download_params)

    render json: { success: false }, status: :forbidden
  end

  def complete_download_params
    params.permit(*@complete_download_class.complete_download_required_params).to_h.symbolize_keys
  end


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
