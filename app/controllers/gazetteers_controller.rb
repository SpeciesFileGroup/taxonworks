class GazetteersController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  before_action :set_gazetteer, only: %i[ show edit update destroy ]

  # GET /gazetteers
  # GET /gazetteers.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = Gazetteer.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json do
        # TODO gzs, not gas
        @geographic_areas = ::Queries::GeographicArea::Filter.new(params).all
          .includes(:geographic_items)
          .page(params[:page])
          .per(params[:per])
          # .order('geographic_items.cached_total_area, geographic_area.name')
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
      format.html { redirect_to new_gazetteer_task_path gazetteer_id: @gazetteer.id }
    end
  end

  # GET /gazetteers/list
  def list
    @gazetteers = Gazetteer
      .with_project_id(sessions_current_project_id)
      .page(params[:page]).per(params[[:per]])
  end

  # POST /gazetteers.json
  def create
    @gazetteer = Gazetteer.new(gazetteer_params)

    begin
      rgeo_shape = Gazetteer.combine_shapes_to_rgeo(shape_params['shapes'])
    # TODO make sure these errors work
    rescue RGeo::Error::RGeoError => e
      @gazetteer.errors.add(:base, e)
    rescue RGeo::Error::InvalidGeometry => e
      @gazetteer.errors.add(:base, "Invalid geometry: #{e}")
    rescue TaxonWorks::Error => e
      @gazetteer.errors.add(:base, e)
    end

    if @gazetteer.errors.include?(:base) || rgeo_shape.nil?
      render json: @gazetteer.errors, status: :unprocessable_entity
      return
    end

    @gazetteer.build_geographic_item(
      type: 'GeographicItem::Geography',
      geography: rgeo_shape
    )

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

  private

  def set_gazetteer
    @gazetteer = Gazetteer.find(params[:id])
  end

  def gazetteer_params
    params.require(:gazetteer).permit(:name, :parent_id,
      :iso_3166_a2, :iso_3166_a3)
    end

  def shape_params
    params.require(:gazetteer).permit(shapes: { geojson: [], wkt: []})
  end


end
