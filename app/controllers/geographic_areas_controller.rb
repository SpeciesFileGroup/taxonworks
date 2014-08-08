class GeographicAreasController < ApplicationController
  include DataControllerConfiguration

  before_action :set_geographic_area, only: [:show, :edit, :update, :destroy]

  # GET /geographic_areas
  # GET /geographic_areas.json
  def index
    @geographic_areas = GeographicArea.limit(30).offset(@geo_area_offset)
    # @recent_objects   = GeographicArea.recent_in_time(1.year).order(updated_at: :desc).limit(10)
    @recent_objects   = GeographicArea.order(updated_at: :desc).limit(10)
  end

  # GET /geographic_areas/1
  # GET /geographic_areas/1.json
  def show
  end

  # GET /geographic_areas/new
  def new
    @geographic_area = GeographicArea.new
  end

  # GET /geographic_areas/1/edit
  def edit
  end

  def list
    @geographic_areas = GeographicArea.order(:id).page(params[:page])
  end

  # POST /geographic_areas
  # POST /geographic_areas.json
  def create
    @geographic_area = GeographicArea.new(geographic_area_params)

    respond_to do |format|
      if @geographic_area.save
        format.html { redirect_to @geographic_area, notice: 'Geographic area was successfully created.' }
        format.json { render action: 'show', status: :created, location: @geographic_area }
      else
        format.html { render action: 'new' }
        format.json { render json: @geographic_area.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /geographic_areas/1
  # PATCH/PUT /geographic_areas/1.json
  def update
    respond_to do |format|
      if @geographic_area.update(geographic_area_params)
        format.html { redirect_to @geographic_area, notice: 'Geographic area was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @geographic_area.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /geographic_areas/1
  # DELETE /geographic_areas/1.json
  def destroy
    @geographic_area.destroy
    respond_to do |format|
      format.html { redirect_to geographic_areas_url }
      format.json { head :no_content }
    end
  end

  def search
    @geographic_areas = GeographicArea.with_name_like(params[:name])
    @search_string    = params[:name]
    render :index
    @geo_area_offset = index
  end

  def autocomplete
    @geographic_areas = GeographicArea.find_for_autocomplete(params)

    data = @geographic_areas.collect do |t|
      {id:              t.id,
       label:           GeographicAreasHelper.geographic_area_tag(t),
       response_values: {
         params[:method] => t.id
       },
       label_html:      GeographicAreasHelper.geographic_area_tag(t)
      }
    end

    render :json => data
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_geographic_area
    @geographic_area = GeographicArea.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def geographic_area_params
    params.require(:geographic_area).permit(:name, :level0_id, :level1_id, :level2_id, :parent_id, :geographic_area_type_id, :iso_3166_a2, :iso_3166_a3, :tdwgID, :data_origin, :created_by_id, :updated_by_id)
  end
end
