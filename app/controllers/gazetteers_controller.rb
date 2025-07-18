class GazetteersController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  include Lib::Vendor::RgeoShapefileHelper
  require_dependency Rails.root.to_s + '/lib/vendor/rgeo.rb'

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
        @gazetteers = ::Queries::Gazetteer::Filter.new(params).all
          .includes(:geographic_item)
          .page(params[:page])
          .per(params[:per])
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

    @gazetteer.build_gi_from_shapes(
      shape_params['shapes'], params.require('geometry_operation_is_union')
    )
    if @gazetteer.errors.include?(:base)
      render json: @gazetteer.errors, status: :unprocessable_entity
      return
    end

    begin
      Gazetteer
        .save_and_clone_to_projects(@gazetteer, projects_param['projects'])

      render :show, status: :created, location: @gazetteer
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.message }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /gazetteers/1
  # PATCH/PUT /gazetteers/1.json
  def update
    @gazetteer.build_gi_from_shapes(
      shape_params['shapes'], params.require('geometry_operation_is_union')
    )
    if @gazetteer.errors.include?(:base)
      render json: @gazetteer.errors, status: :unprocessable_entity
      return
    end

    begin
      @gazetteer.update!(gazetteer_params)
      render :show, status: :created, location: @gazetteer
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.message }, status: :unprocessable_entity
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
      addShapefileImportJobToQueue(
        shapefile_params,
        citation_params, projects_param['projects'],
        sessions_current_project_id, sessions_current_user_id
      )
    rescue TaxonWorks::Error => e
      render json: { errors: e.message }, status: :unprocessable_entity
      return
    end

    head :no_content
  end

  # Using POST instead of GET to support long WKT strings
  # POST /gazetteers/preview.json
  def preview
    begin
      s = Gazetteer.combine_shapes_to_rgeo(
        shape_params['shapes'], params.require('geometry_operation_is_union')
      )
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

  # GET /gazetteers/shapefile_text_field_values.json
  def shapefile_text_field_values
    begin
      text_data_hash = validate_and_fetch_shapefile_text_field_values(
        shapefile_params, sessions_current_project_id
      )
    rescue TaxonWorks::Error => e
      render json: { errors: e }, status: :unprocessable_entity
      return
    end

    render json: text_data_hash
  end

  # GET /gazetteers/select_options.json
  def select_options
    @gazetteers = Gazetteer.select_optimized(
      sessions_current_user_id, sessions_current_project_id,
      params.permit(:target)[:target]
    )
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
      shapes: { geojson: [], wkt: [], points: [], ga_combine: [], gz_combine: [] }
    )
  end

  def shapefile_params
    params.require(:shapefile).permit(
      :shp_doc_id, :shx_doc_id, :dbf_doc_id, :prj_doc_id, :cpg_doc_id,
      :name_field, :iso_a2_field, :iso_a3_field
    )
  end

  def citation_params
    params.require(:citation_options).permit(
      :cite_gzs, citation: [:source_id, :pages, :is_original]
    )
  end

end
