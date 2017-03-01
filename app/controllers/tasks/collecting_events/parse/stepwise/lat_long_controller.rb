class Tasks::CollectingEvents::Parse::Stepwise::LatLongController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @collecting_events = Queries::CollectingEventLatLongExtractorQuery
                           .new(collecting_event_id: collecting_event_id_param,
                                project_id:          sessions_current_project_id,
                                filters:             [:dd, :d_dm]).all.limit(5)

  end

  def convert
    retval              = {}
    retval[:lat_piece]  = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(params[:verbatim_latitude])
    retval[:long_piece] = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(params[:verbatim_longitude])
    render :json => retval
  end

  def update

    redirect_to(lat_long_skip_record_path)
  end

  def skip_record
    redirect_to(collecting_event_lat_long_task_path(collecting_event_id: CollectingEvent
                                                                           .with_project_id(sessions_current_project_id)
                                                                           .where('id > ?',
                                                                                  collecting_event_id_param).limit(1).pluck(:id)[0]))
  end

  def similar_labels
    @similar_labels = CollectingEvent.where('id > 969')
  end

  protected

  def collecting_event_id_param
    begin
      params.require(:collecting_event_id)
    rescue ActionController::ParameterMissing
      return CollectingEvent.with_project_id(sessions_current_project_id).order(:id).limit(1).pluck(:id)[0]
    end
  end

  def current_collecting_event
    CollectingEvent.find(collecting_event_id_param)
  end

  def lat_long_params
    params.permit(:verbatim_latitude, :verbatim_longitude, :collecting_event_id)
  end

end
