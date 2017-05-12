class GeographicAreaTypesController < ApplicationController
  include DataControllerConfiguration::SharedDataControllerConfiguration

  before_action :set_geographic_area_type, only: [:show, :edit, :update, :destroy]

  # GET /geographic_area_types
  # GET /geographic_area_types.json
  def index
    @geographic_area_types = GeographicAreaType.all
    render '/shared/data/all/index'
  end

  # GET /geographic_area_types/1
  # GET /geographic_area_types/1.json
  def show
  end

  # GET /geographic_area_types/new
  def new
    @geographic_area_type = GeographicAreaType.new
  end

  # GET /geographic_area_types/1/edit
  def edit
  end

  # POST /geographic_area_types
  # POST /geographic_area_types.json
  def create
    @geographic_area_type = GeographicAreaType.new(geographic_area_type_params)
    @geographic_area_type.created_by_id = sessions_current_user.id
    @geographic_area_type.updated_by_id = sessions_current_user.id

    respond_to do |format|
      if @geographic_area_type.save
        format.html { redirect_to @geographic_area_type, notice: 'Geographic area type was successfully created.' }
        format.json { render action: 'show', status: :created, location: @geographic_area_type }
      else
        format.html { render action: 'new' }
        format.json { render json: @geographic_area_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /geographic_area_types/1
  # PATCH/PUT /geographic_area_types/1.json
  def update
    respond_to do |format|
      if @geographic_area_type.update(geographic_area_type_params)
        format.html { redirect_to @geographic_area_type, notice: 'Geographic area type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @geographic_area_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /geographic_area_types/1
  # DELETE /geographic_area_types/1.json
  def destroy
    @geographic_area_type.destroy
    respond_to do |format|
      format.html { redirect_to geographic_area_types_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_geographic_area_type
    @geographic_area_type = GeographicAreaType.find(params[:id])
    @recent_object = @geographic_area_type 
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def geographic_area_type_params
    params.require(:geographic_area_type).permit(:name)
  end
end
