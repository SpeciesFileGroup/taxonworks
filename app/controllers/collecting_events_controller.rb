class CollectingEventsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_collecting_event, only: [:show, :edit, :update, :destroy]

  # GET /collecting_events
  # GET /collecting_events.json
  def index
    @recent_objects = CollectingEvent.recent_from_project_id($project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /collecting_events/1
  # GET /collecting_events/1.json
  def show
  end

  # GET /collecting_events/new
  def new
    @collecting_event = CollectingEvent.new
  end

  # GET /collecting_events/1/edit
  def edit
  end

  # POST /collecting_events
  # POST /collecting_events.json
  def create
    @collecting_event = CollectingEvent.new(collecting_event_params)
    respond_to do |format|
      if @collecting_event.save
        format.html { redirect_to @collecting_event, notice: 'Collecting event was successfully created.' }
        format.json { render action: 'show', status: :created, location: @collecting_event }
      else
        format.html { render action: 'new' }
        format.json { render json: @collecting_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collecting_events/1
  # PATCH/PUT /collecting_events/1.json
  def update
    respond_to do |format|
      if @collecting_event.update(collecting_event_params)
        format.html { redirect_to @collecting_event, notice: 'Collecting event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @collecting_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collecting_events/1
  # DELETE /collecting_events/1.json
  def destroy
    @collecting_event.destroy
    respond_to do |format|
      format.html { redirect_to collecting_events_url }
      format.json { head :no_content }
    end
  end

  def test
    @geo = CollectingEvent.test
  end

  def list
    @collecting_events = CollectingEvent.with_project_id($project_id).order(:id).page(params[:page]) 
  end

  # GET /collecting_events/search
  def search
    if params[:id].blank?
      redirect_to collecting_event_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to collecting_event_path(params[:id])
     end
  end

  def autocomplete
    @collecting_events = CollectingEvent.find_for_autocomplete(params.merge(project_id: sessions_current_project_id)) 

    data = @collecting_events.collect do |t|
      str = render_to_string(partial: 'tag', locals: {collecting_event: t})
      {id:              t.id,
       label:           str, 
       response_values: {
         params[:method] => t.id
       },
       label_html:      str  
      }
    end

    render :json => data
  end

  # GET /collecting_events/download
  def download
    send_data CollectingEvent.generate_download( CollectingEvent.where(project_id: $project_id) ), type: 'text', filename: "collecting_events_#{DateTime.now.to_s}.csv"
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_collecting_event
    @collecting_event = CollectingEvent.with_project_id($project_id).find(params[:id])
    @recent_object = @collecting_event 
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def collecting_event_params
    params.require(:collecting_event).permit(
      :verbatim_label, :print_label, :print_label_number_to_print, :document_label,
      :verbatim_locality, :verbatim_date, :verbatim_longitude, :verbatim_latitude,
      :verbatim_geolocation_uncertainty, :verbatim_trip_identifier, :verbatim_collectors,
      :verbatim_method, :geographic_area_id, :minimum_elevation, :maximum_elevation,
      :elevation_precision, :time_start_hour, :time_start_minute, :time_start_second,
      :time_end_hour, :time_end_minute, :time_end_second, :start_date_day,
      :start_date_month, :start_date_year, :end_date_day, :end_date_month,
      :end_date_year, :verbatim_habitat,  :field_notes, :verbatim_datum, 
      roles_attributes: [:id, :_destroy, :type, :person_id, :position, person_attributes: [:last_name, :first_name, :suffix, :prefix]]
    )
  end
end
