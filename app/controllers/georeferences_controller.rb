class GeoreferencesController < ApplicationController
  before_action :set_georeference, only: [:show, :edit, :update, :destroy]

  # GET /georeferences
  # GET /georeferences.json
  def index
    @georeferences = Georeference.all
  end

  # GET /georeferences/1
  # GET /georeferences/1.json
  def show
  end

  # GET /georeferences/new
  def new
    @georeference = Georeference.new
  end

  # GET /georeferences/1/edit
  def edit
  end

  # POST /georeferences
  # POST /georeferences.json
  def create
    @georeference = Georeference.new(georeference_params)

    respond_to do |format|
      if @georeference.save
        format.html { redirect_to @georeference, notice: 'Georeference was successfully created.' }
        format.json { render action: 'show', status: :created, location: @georeference }
      else
        format.html { render action: 'new' }
        format.json { render json: @georeference.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /georeferences/1
  # PATCH/PUT /georeferences/1.json
  def update
    respond_to do |format|
      if @georeference.update(georeference_params)
        format.html { redirect_to @georeference, notice: 'Georeference was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @georeference.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /georeferences/1
  # DELETE /georeferences/1.json
  def destroy
    @georeference.destroy
    respond_to do |format|
      format.html { redirect_to georeferences_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_georeference
      @georeference = Georeference.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def georeference_params
      params.require(:georeference).permit(:geographic_item_id, :collecting_event_id, :error_radius, :error_depth, :error_geographic_item_id, :type, :source_id, :position, :is_public, :api_request, :created_by_id, :updated_by_id, :project_id, :is_undefined_z, :is_median_z)
    end
end
