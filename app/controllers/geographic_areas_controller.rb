class GeographicAreasController < ApplicationController
  before_action :set_geographic_area, only: [:show, :edit, :update, :destroy]

  # GET /geographic_areas
  # GET /geographic_areas.json
  def index
    @geographic_areas = GeographicArea.limit(30)
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
    @search_string = params[:name]
    render :index 
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_geographic_area
      @geographic_area = GeographicArea.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def geographic_area_params
      params.require(:geographic_area).permit(:name, :level0_id, :level1_id, :level2_id, :gadm_geo_item_id, :parent_id, :geographic_area_type_id, :iso_3166_a2, :rgt, :lft, :tdwg_parent_id, :iso_3166_a3, :tdwg_geo_item_id, :tdwgID, :gadmID, :gadm_valid_from, :gadm_valid_to, :data_origin, :adm0_a3, :neID, :created_by_id, :updated_by_id, :ne_geo_item_id)
    end
end
