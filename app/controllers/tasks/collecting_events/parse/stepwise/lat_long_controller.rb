class Tasks::CollectingEvents::Parse::Stepwise::LatLongController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @collecting_event = current_collecting_event 
    if @collecting_event.nil?
      flash['notice'] = 'No collecting events with parsable records found.'
      redirect_to hub_path and return
    end
  end

  def update
    if current_collecting_event.update_attributes(collecting_event_params)
      collecting_event.generate_verbatim_data_georeference(true) if generate_georeference? 
      flash['notice'] = 'Updated.'
    else
      flash['alert'] = 'Failed to update the collecting event.'
      redirect_to collecting_event_lat_long_task_path(collecting_event_id: current_collecting_event.id) and return
    end

    # TODO: pass in next as determined in view
    redirect_to collecting_event_lat_long_task_path(collecting_event_id: next_collecting_event_id)
  end

  def convert
    retval = {}
    retval[:lat_piece] = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(params[:verbatim_latitude])
    retval[:long_piece] = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(params[:verbatim_longitude])
    render json: retval
  end

  def similar_labels
    # @similar_labels = CollectingEvent.where('id > ?', next_record).limit(5)
  end

  protected

  def collecting_event_id_param
    begin
      params.require(:collecting_event_id)
    rescue ActionController::ParameterMissing
      # nothing provided, get the first possible one 
      return CollectingEvent.with_project_id(sessions_current_project_id).order(:id).limit(1).pluck(:id)[0]
    end
  end

  # TODO: deprecate for valud from view/helper 
  def next_collecting_event_id
    Queries::CollectingEventLatLongExtractorQuery.new(
      collecting_event_id: collecting_event_id_param,
      filters: [:dd, :d_dm]).all.with_project_id(sessions_current_project_id).first.id
  end

  def current_collecting_event
    CollectingEvent.find(collecting_event_id_param)
  end

  def collecting_event_params
    params.permit(:verbatim_latitude, :verbatim_longitude)
  end

  def generate_georeference?
    !params[:generate_georeference].blank?
  end

end
