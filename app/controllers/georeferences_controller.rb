class GeoreferencesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_georeference, only: [:show, :edit, :update, :destroy]
  before_action :disable_turbolinks, only: [:show, :list, :index]

  # GET /georeferences
  # GET /georeferences.json
  def index
    @recent_objects = Georeference.recent_from_project_id($project_id).order(updated_at: :desc).limit(10)
  end

  def list
    @georeferences = Georeference.with_project_id($project_id).order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  # GET /georeferences/1
  # GET /georeferences/1.json
  def show
  end

  # GET /georeferences/new
  def new
    @collecting_event = CollectingEvent.find(params.permit(:collecting_event_id)[:collecting_event_id]) if params.permit(:collecting_event_id)[:collecting_event_id]
    @georeference     = Georeference.new(collecting_event: @collecting_event)
  end

  # GET /georeferences/1/edit
  def edit
  end

  # POST /georeferences
  # POST /georeferences.json
  def create
    # geographic_item is embedded in the params
    @georeference = Georeference.new(georeference_params)
    respond_to do |format|
      if @georeference.save
        format.html { redirect_to @georeference.metamorphosize, notice: 'Georeference was successfully created.' }
        format.json { render action: 'show', status: :created, location: @georeference }
      else
        # format.html { render action: 'new', notice: 'Georeference was NOT successfully created.' }
        format.html { redirect_to :back, notice: 'Georeference was NOT successfully created.' }
        # format.html { render partial: '/georeferences/google_maps/form', notice: 'Georeference was NOT successfully created.' }
        format.json { render json: @georeference.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /georeferences/1
  # PATCH/PUT /georeferences/1.json
  def update
    respond_to do |format|
      if @georeference.update(georeference_params)

        format.html { redirect_to @georeference.metamorphosize, notice: 'Georeference was successfully updated.' }
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

  # GET /georeferences/download
  def download
    send_data Georeference.generate_download(Georeference.where(project_id: $project_id)), type: 'text', filename: "georeferences_#{DateTime.now.to_s}.csv"
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_georeference
    @georeference = Georeference.with_project_id($project_id).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def georeference_params
    params.require(:georeference).permit(:iframe_response,
                                         :geographic_item_id,
                                         :collecting_event_id,
                                         :error_radius,
                                         :error_depth,
                                         :error_geographic_item_id,
                                         :type,
                                         :source_id,
                                         :position,
                                         :is_public,
                                         :api_request,
                                         :is_undefined_z,
                                         :is_median_z,
                                         :geographic_item_attributes => [:shape])
  end
end
