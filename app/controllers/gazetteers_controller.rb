class GazetteersController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  include Lib::Vendor::RgeoShapefileHelper
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
        return
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

    begin
      Gazetteer.clone_to_projects(@gazetteer, projects_param['projects'])
      render :show, status: :created, location: @gazetteer
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.message }, status: :unprocessable_entity
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
    @gazetteer.destroy!

    respond_to do |format|
      format.html {
        redirect_to gazetteers_url,
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

  # GET /gazetteers/download
  def download
    send_data Export::CSV.generate_csv(
        Gazetteer.where(project_id: sessions_current_project_id)
      ),
      type: 'text',
      filename: "gazetteers_#{DateTime.now}.tsv"
  end

  # POST /gazetteers/import.json
  def import
    begin
      shapefile_docs = validate_shape_file(
        shapefile_params, sessions_current_project_id
      )
    rescue TaxonWorks::Error => e
      render json: { errors: e.message }, status: :unprocessable_entity
      return
    end

    if citation_params[:cite_gzs] &&
       !citation_params[:citation]&.dig(:source_id)
      render json: { errors: 'No citation source selected' },
        status: :unprocessable_entity
      return
    end

    new_params = shapefile_params
    # shp_doc_id was required, the following may have been determined instead
    # during validation.
    new_params[:shx_doc_id] = shapefile_docs[:shx].id
    new_params[:dbf_doc_id] = shapefile_docs[:dbf].id
    new_params[:prj_doc_id] = shapefile_docs[:prj].id

    progress_tracker = GazetteerImport.create!(
      shapefile: shapefile_docs[:shp].document_file_file_name
    )
    ImportGazetteersJob.perform_later(
      new_params, citation_params,
      sessions_current_user_id, sessions_current_project_id,
      progress_tracker,
      projects_param['projects']
    )

    head :no_content
  end

  # Using POST instead of GET to support long WKT strings
  # POST /gazetteers/preview.json
  def preview
    begin
      s = Gazetteer.combine_shapes_to_rgeo(shape_params['shapes'])
    rescue TaxonWorks::Error => e
      render json: { base: [e.message] }, status: :unprocessable_entity
      return
    end

    f = RGeo::GeoJSON::Feature.new(s)
    @shape = RGeo::GeoJSON.encode(f)
  end

  # GET /gazetteers/shapefile_fields.json
  def shapefile_fields
    begin
      @shapefile_fields =
        fields_from_shapefile(
          params[:shp_doc_id], params[:dbf_doc_id], sessions_current_project_id
        )
    rescue TaxonWorks::Error => e
      render json: { errors: e }, status: :unprocessable_entity
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

  def projects_param
    params.permit(projects: [])
  end

  def shape_params
    params.require(:gazetteer).permit(
      shapes: { geojson: [], wkt: [], points: [], ga_union: [], gz_union: [] }
    )
  end

  def shapefile_params
    params.require(:shapefile).permit(
      :shp_doc_id, :shx_doc_id, :dbf_doc_id, :prj_doc_id, :name_field,
      :iso_a2_field, :iso_a3_field
    )
  end

  def citation_params
    params.require(:citation_options).permit(
      :cite_gzs, citation: [:source_id, :pages, :is_original]
    )
  end

end
