class Georeferences::GoogleMapsController < ApplicationController
  # include DataControllerConfiguration::ProjectDataControllerConfiguration

  # before_action :set_georeference, only: [:show, :edit, :update, :destroy]
  before_action :disable_turbolinks, only: [:new]

  # GET /georeferences/google_maps/new
  def new
    @collecting_event = CollectingEvent.find(params.permit(:collecting_event_id)[:collecting_event_id]) if params.permit(:collecting_event_id)[:collecting_event_id]
    @georeference     = Georeference::GoogleMap.new(collecting_event: @collecting_event, geographic_item: GeographicItem.new)

    @feature_collection = Gis::GeoJSON.feature_collection(@collecting_event.georeferences)
    @map_center = Georeference::VerbatimData.new(collecting_event: @georeference.collecting_event).geographic_item.geo_object.to_s

  end

  def re_new
    errors = @georeference.errors
  end

  # POST /georeferences
  # POST /georeferences.json
  # def create
  #   @georeference = Georeference::GoogleMap.new(georeference_google_map_params)
  #   respond_to do |format|
  #     if @georeference.save
  #       format.html { redirect_to @georeference.metamorphosize, notice: 'Georeference was successfully created.' }
  #       format.json { render action: 'show', status: :created, location: @georeference }
  #     else
  #       format.html { render action: 'new' }
  #       format.json { render json: @georeference.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # GET /georeferences/download
  # def download
  #   send_data Georeference.generate_download( Georeference.where(project_id: $project_id) ), type: 'text', filename: "georeferences_#{DateTime.now.to_s}.csv"
  # end

  def new_map_item
    # @asserted_distribution = AssertedDistributions.new(asserted_distribution_params)
    # @otu                = Otu.find(params[:asserted_distribution][:otu_id])
    # todo: this needs to be tested and accounted for in maps.js
    @feature_collection = ::Gis::GeoJSON.feature_collection([])
    # source_id           = params[:asserted_distribution][:source_id]
    # @source             = Source.find(source_id) unless source_id.blank?
  end

  def create_map_item
  end

  def collect_item
    @type        = params['type']
    @coordinates = params['coordinates']
    u            = 0
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_georeference
    @georeference = Georeference.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  # @return [Object]
  def georeference_google_map_params
    params.require(:georeference_google_map).permit(:collecting_event_id,
                                                    :type,
                                                    :shape,
                                                    :geo_type
    )
  end
end
