class Tasks::Import::Dwca::PsuImportController < ApplicationController
  include TaskControllerConfiguration

  # rails generate taxonworks:task psu_import "import/dwca/" index:get:psu_import preview_psu_import:post:preview_psu_import do_psu_import:post:do_psu_import

  # GET
  def index
  end

  # POST
  def preview_psu_import
    if params[:file]
      @result = BatchLoad::Import::DWCA.new(import_params)
      digest_cookie(params[:file].tempfile, :psu_import_md5)
      render 'preview_psu_import'
    else
      flash[:notice] = "No file provided!"
      redirect_to action: :index
    end
  end

  # POST
  def do_psu_import
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :psu_import_md5)
      @result = BatchLoad::Import::DWCA.new(import_params)
      if @result.create
        flash[:notice] = "Successfully proccessed file, #{@result.total_records_created} rows processed."
        render 'collecting_events/batch_load/simple/create' and return
      else
        flash[:alert] = 'Batch import failed.'
      end
    else
      flash[:alert] = 'File to batch upload must be supplied.'
    end
    render :index
  end

  private
  def import_params
    params.permit(:ce_namespace, :file, :import_level).merge(user_id: sessions_current_user_id, project_id: sessions_current_project_id).symbolize_keys
  end


end
