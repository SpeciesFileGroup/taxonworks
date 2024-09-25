class GazetteersController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  before_action :set_gazetteer, only: %i[ show edit update destroy ]

  # GET /gazetteers
  # GET /gazetteers.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = Gazetteer
          .recent_from_project_id(sessions_current_project_id)
          .order(updated_at: :desc)
          .limit(10)
        render '/shared/data/all/index'
      end
      format.json do
        # no filter on GZs yet
      end
    end
  end

  # GET /gazetteers/1 or /gazetteers/1.json
  def show
  end

  # GET /gazetteers/new
  def new
    respond_to do |format|
      format.html { redirect_to new_gazetteer_task_path }
    end
  end

  # GET /gazetteers/1/edit
  def edit
    respond_to do |format|
      format.html {
        redirect_to new_gazetteer_task_path gazetteer_id: @gazetteer.id
      }
    end
  end

  # GET /gazetteers/list
  def list
    @gazetteers = Gazetteer
      .with_project_id(sessions_current_project_id)
      .page(params[:page]).per(params[:per])
  end

  # POST /gazetteers.json
  def create
    @gazetteer = Gazetteer.new(gazetteer_params)

    @gazetteer.build_gi_from_shapes(shape_params['shapes'])
    if @gazetteer.errors.include?(:base)
      render json: @gazetteer.errors, status: :unprocessable_entity
      return
    end

    if @gazetteer.save
      render :show, status: :created, location: @gazetteer
    else
      render json: @gazetteer.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /gazetteers/1
  # PATCH/PUT /gazetteers/1.json
  def update
    respond_to do |format|
      if @gazetteer.update(gazetteer_params)
        format.html { redirect_to gazetteer_url(@gazetteer) }
        format.json { render :show, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @gazetteer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gazetteers/1
  # DELETE /gazetteers/1.json
  def destroy
    # TODO Handle children/parents (if used)
    @gazetteer.destroy!

    respond_to do |format|
      format.html {
        redirect_to gazetteers_url,
          # TODO this doesn't work
          notice: 'Gazetteer was successfully destroyed.'
      }
      format.json { head :no_content }
    end
  end

  def autocomplete
    @gazetteers = ::Queries::Gazetteer::Autocomplete.new(
      params.require(:term),
      project_id: sessions_current_project_id,
    ).autocomplete
  end

  def search
    if params[:id].blank?
      redirect_to(gazetteer_path,
                  alert: 'You must select an item from the list with a click or tab press before clicking show.')
    else
      redirect_to gazetteer_path(params[:id])
    end
  end

  # POST /gazetteers/import.json
  def import
    rv = Gazetteer.validate_shape_file(shapefile_params)

    if rv == true &&
       citation_params[:cite_gzs] &&
       !citation_params[:citation]&.dig(:source_id)
      rv = 'Citation option checked but no source selected'
    end

    if rv != true
      render json: {
        errors: rv
      },
      status: :unprocessable_entity
      return
    end

    shp_doc = Document.find(shapefile_params[:shp_doc_id])
    progress_tracker = GazetteerImport.create!(
      shapefile: shp_doc.document_file_file_name
    )
    ImportGazetteersJob.perform_later(
      shapefile_params, citation_params,
      sessions_current_user_id, sessions_current_project_id,
      progress_tracker
    )
    #Gazetteer.import_from_shapefile(shapefile_params)
    head :no_content
  end

  # POST to support long WKT strings
  # POST /gazetteers/preview.json
  def preview
    s = Gazetteer.combine_shapes_to_rgeo(shape_params['shapes'])
    f = RGeo::GeoJSON::Feature.new(s)
    @shape = RGeo::GeoJSON.encode(f)
  end

  # GET /gazetteers/shapefile_fields.json
  def shapefile_fields
    begin
      @shapefile_fields = Gazetteer.fields_from_shapefile(params[:dbf_doc_id])
    rescue TaxonWorks::Error => e
      render json: {
        errors: e
      },
      status: :unprocessable_entity
      return
    end
  end

  private

  def set_gazetteer
    @gazetteer = Gazetteer.find(params[:id])
  end

  def gazetteer_params
    params.require(:gazetteer).permit(:name, :parent_id,
      :iso_3166_a2, :iso_3166_a3)
  end

  def shape_params
    params.require(:gazetteer).permit(
      shapes: { geojson: [], wkt: [], points: [], ga_union: [], gz_union: [] }
    )
  end

  def shapefile_params
    params.require(:shapefile).permit(
      :shp_doc_id, :shx_doc_id, :dbf_doc_id, :prj_doc_id, :name_field
    )
  end

  def citation_params
    params.require(:citation_options).permit(
      :cite_gzs, citation: [:source_id, :pages, :is_original]
    )
  end

end
