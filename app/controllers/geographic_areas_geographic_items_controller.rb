class GeographicAreasGeographicItemsController < ApplicationController
  include DataControllerConfiguration

  before_action :require_sign_in_and_project_selection
  before_action :set_geographic_areas_geographic_item, only: [:show, :edit, :update, :destroy]

  # GET /geographic_areas_geographic_items
  # GET /geographic_areas_geographic_items.json
  def index
    @geographic_areas_geographic_items = GeographicAreasGeographicItem.limit(30)
  end

  # GET /geographic_areas_geographic_items/1
  # GET /geographic_areas_geographic_items/1.json
  def show
  end

  # GET /geographic_areas_geographic_items/new
  def new
    @geographic_areas_geographic_item = GeographicAreasGeographicItem.new
  end

  # GET /geographic_areas_geographic_items/1/edit
  def edit
  end

  # POST /geographic_areas_geographic_items
  # POST /geographic_areas_geographic_items.json
  def create
    @geographic_areas_geographic_item = GeographicAreasGeographicItem.new(geographic_areas_geographic_item_params)

    respond_to do |format|
      if @geographic_areas_geographic_item.save
        format.html { redirect_to @geographic_areas_geographic_item, notice: 'Geographic areas geographic item was successfully created.' }
        format.json { render action: 'show', status: :created, location: @geographic_areas_geographic_item }
      else
        format.html { render action: 'new' }
        format.json { render json: @geographic_areas_geographic_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /geographic_areas_geographic_items/1
  # PATCH/PUT /geographic_areas_geographic_items/1.json
  def update
    respond_to do |format|
      if @geographic_areas_geographic_item.update(geographic_areas_geographic_item_params)
        format.html { redirect_to @geographic_areas_geographic_item, notice: 'Geographic areas geographic item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @geographic_areas_geographic_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /geographic_areas_geographic_items/1
  # DELETE /geographic_areas_geographic_items/1.json
  def destroy
    @geographic_areas_geographic_item.destroy
    respond_to do |format|
      format.html { redirect_to geographic_areas_geographic_items_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_geographic_areas_geographic_item
      @geographic_areas_geographic_item = GeographicAreasGeographicItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def geographic_areas_geographic_item_params
      params.require(:geographic_areas_geographic_item).permit(:geographic_area_id, :geographic_item_id, :data_origin, :origin_gid, :date_valid_from, :date_valid_to)
    end
end
