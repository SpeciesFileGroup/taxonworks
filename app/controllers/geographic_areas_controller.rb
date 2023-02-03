class GeographicAreasController < ApplicationController
  include DataControllerConfiguration::SharedDataControllerConfiguration

  before_action :set_geographic_area, only: [:show]

  # GET /geographic_areas
  # GET /geographic_areas.json
  def index
    @recent_objects = GeographicArea.updated_in_last(2.months).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /geographic_areas/1
  # GET /geographic_areas/1.json
  def show
  end

  def display_coordinates
    @asserted_distribution = AssertedDistribution.new
    @json_coors = params.to_json
    render partial: '/asserted_distributions/quick_form'
  end

  def list
    @geographic_areas = GeographicArea.order(:id).page(params[:page])
  end

  def search
    if params[:id].blank?
      redirect_to geographic_areas_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to geographic_area_path(params[:id])
    end
  end

  def autocomplete
    c = Queries::GeographicArea::Autocomplete.new(params[:term]).autocomplete
    @geographic_areas = c.sort_by{|geographic_area|
      -(geographic_area.collecting_events.where(project_id: sessions_current_project_id).count + geographic_area.asserted_distributions.where(project_id: sessions_current_project_id).count + (geographic_area.has_shape? && 1||0))
    }
  end

  # GET /geographic_areas/download
  def download
    send_data Export::Download.generate_csv(GeographicArea.all), type: 'text', filename: "geographic_areas_#{DateTime.now}.csv"
  end

  # GET /geographic_areas/select_options.json
  def select_options
    @geographic_areas = GeographicArea.select_optimized(sessions_current_user_id, sessions_current_project_id, params.permit(:target)[:target])
  end

  # !! Almost certain @mjy did similar somewhere else too !!
  # GET /geographic_areas/by_lat_long.json?latitude=0.0&longitude=10.1
  def by_lat_long
    @geographic_areas = GeographicArea.find_smallest_by_lat_long(
      params.require(:latitude).to_f,
      params.require(:longitude).to_f
    )
    render action: :autocomplete
  end

  private

  def set_geographic_area
    @geographic_area = GeographicArea.find(params[:id])
    @recent_object = @geographic_area
  end

  def geographic_area_params
    params.require(:geographic_area).permit(
      :name, :level0_id, :level1_id, :level2_id, :parent_id,
      :geographic_area_type_id, :iso_3166_a2, :iso_3166_a3, :tdwgID,
      :data_origin)
  end
end
