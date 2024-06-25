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
    @gazetteer = Gazetteer.new
  end

  # GET /gazetteers/1/edit
  def edit
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

    shape = combine_geojson_shapes_to_rgeo(shape_params['shapes']['geojson'])
    if shape.nil?
      render json: @gazetteer.errors, status: :unprocessable_entity
      return
    end

    @gazetteer.geographic_item = GeographicItem.new(geography: shape)

    if @gazetteer.save
      render :show, status: :created, location: @gazetteer
      # TODO make this notice work
      flash[:notice] = 'Gazetteer created.'
    else
      render json: @gazetteer.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /gazetteers/1
  # PATCH/PUT /gazetteers/1.json
  def update
    respond_to do |format|
      if @gazetteer.update(gazetteer_params)
        format.html { redirect_to gazetteer_url(@gazetteer), notice: "Gazetteer was successfully updated." }
        # TODO Add updated message
        format.json { render :show, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @gazetteer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gazetteers/1 or /gazetteers/1.json
  def destroy
    @gazetteer.destroy!

    respond_to do |format|
      format.html { redirect_to gazetteers_url, notice: "Gazetteer was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_gazetteer
    @gazetteer = Gazetteer.find(params[:id])
  end

  def gazetteer_params
    params.require(:gazetteer).permit(:name, :parent_id, :iso_3166_a2, :iso_3166_a3)
  end

  def shape_params
    params.require(:gazetteer).permit(shapes: { geojson: []})
  end

  # Adds to errors and returns nil on error
  def geojson_to_rgeo(shape)
    begin
      RGeo::GeoJSON.decode(shape, json_parser: :json, geo_factory: Gis::FACTORY)
    rescue RGeo::Error::InvalidGeometry => e
      @gazetteer.errors.add(:base, "invalid geometry: #{e}")
      return nil
    end
  end

  def combine_geojson_shapes_to_rgeo(shapes)
    if shapes.empty?
      @gazetteer.errors.add(:base, 'No shapes provided')
      return nil
    end

    if shapes.count == 1
      return geojson_to_rgeo(shapes[0]).geometry
    end

    # Attempt to combine multiple shapes into a single geometry
    multi = nil
    type = nil
    rgeo_shapes = shapes.map { |shape| geojson_to_rgeo(shape) }
    if rgeo_shapes.include?(nil)
      return nil
    end

    types = rgeo_shapes.map { |shape|
      # TODO does this always work? (see cases in shape=)
      shape.geometry.geometry_type.type_name
    }.uniq

    if types.count == 1
      type = types[0]
      case type
      when 'Point'
        points = rgeo_shapes.map { |shape| shape.geometry }
        multi = Gis::FACTORY.multi_point(points)
      when 'LineString'
        line_strings = rgeo_shapes.map { |shape| shape.geometry }
        multi = Gis::FACTORY.multi_line_string(line_strings)
      when 'Polygon'
        polygons = rgeo_shapes.map { |shape| shape.geometry }
        multi = Gis::FACTORY.multi_polygon(polygons)
      when 'GeometryCollection'
        geom_collections = rgeo_shapes.map { |shape| shape.geometry }
        multi = Gis::FACTORY.collection(geom_collections)
      end
    else # multiple geometries of different types
      type = 'GeometryCollection'
      # This could itself include GeometryCollection(s)
      various = rgeo_shapes.map { |shape| shape.geometry }
      multi = Gis::FACTORY.collection(various)
    end

    if multi.nil?
      @gazetteer.errors.add(:base,
        "Error in combining multiple #{type}s into a multi-#{type}"
      )
      return nil
    end

    multi
  end
end
