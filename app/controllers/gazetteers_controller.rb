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

    shape = combine_shapes_to_rgeo(shape_params['shapes'])
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
    params.require(:gazetteer).permit(shapes: { geojson: [], wkt: []})
  end

  # @return [Array] of RGeo::Geographic::Projected*Impl
  def convert_geojson_to_rgeo(shapes)
    return [] if shapes.blank?

    rgeo_shapes = shapes.map { |shape|
      begin
        RGeo::GeoJSON.decode(
          shape, json_parser: :json, geo_factory: Gis::FACTORY
        )
      rescue RGeo::Error::InvalidGeometry => e
        @gazetteer.errors.add(:base, "invalid geometry: #{e}")
        nil
      end
    }
    if rgeo_shapes.include?(nil)
      return nil
    end

    rgeo_shapes.map { |shape| shape.geometry }
  end

  # @return [Array] of RGeo::Geographic::Projected*Impl
  def convert_wkt_to_rgeo(wkt_shapes)
    return [] if wkt_shapes.blank?

    rgeo_shapes = wkt_shapes.map { |shape|
      begin
        ::Gis::FACTORY.parse_wkt(shape)
      rescue RGeo::Error::RGeoError => e
        @gazetteer.errors.add(:base, "invalid WKT: #{e}")
        nil
      end
    }
    if rgeo_shapes.include?(nil)
      return nil
    end

    rgeo_shapes
  end

  # Assumes @gazetteer is set
  # @param [Hash]
  # @return A single rgeo shape containing all of the input shapes, or nil on
  #   error with @gazetteer.errors set
  def combine_shapes_to_rgeo(shapes)
    if shapes['geojson'].blank? && shapes['wkt'].blank?
      @gazetteer.errors.add(:base, 'No shapes provided')
      return nil
    end

    geojson_rgeo = convert_geojson_to_rgeo(shapes['geojson'])
    wkt_rgeo = convert_wkt_to_rgeo(shapes['wkt'])
    if geojson_rgeo.nil? || wkt_rgeo.nil?
      return nil
    end

    shapes = geojson_rgeo + wkt_rgeo

    combine_rgeo_shapes(shapes)
  end

  # @param [Array] rgeo_shapes of RGeo::Geographic::Projected*Impl
  # @return [RGeo::Geographic::Projected*Impl] A single shape combining all of the
  #   input shapes
  def combine_rgeo_shapes(rgeo_shapes)
    if rgeo_shapes.count == 1
      return rgeo_shapes[0]
    end

    multi = nil
    type = nil

    types = rgeo_shapes.map { |shape|
      shape.geometry_type.type_name
    }.uniq

    if types.count == 1
      type = types[0]
      case type
      when 'Point'
        multi = Gis::FACTORY.multi_point(rgeo_shapes)
      when 'LineString'
        multi = Gis::FACTORY.multi_line_string(rgeo_shapes)
      when 'Polygon'
        multi = Gis::FACTORY.multi_polygon(rgeo_shapes)
      when 'GeometryCollection'
        multi = Gis::FACTORY.collection(rgeo_shapes)
      end
    else # multiple geometries of different types
      type = 'GeometryCollection'
      # This could itself include GeometryCollection(s)
      multi = Gis::FACTORY.collection(rgeo_shapes)
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
