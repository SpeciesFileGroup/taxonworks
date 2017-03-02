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
    ce = CollectingEvent.find(lat_long_params[:collecting_event_id])
    unless ce.nil?
      p_lat                 = lat_long_params[:verbatim_latitude]
      p_long                = lat_long_params[:verbatim_longitude]
      g_g                   = lat_long_params[:gen_georef_box]
      ce.verbatim_latitude  = (p_lat.blank? ? nil : p_lat)
      ce.verbatim_longitude = (p_long.blank? ? nil : p_long)
      unless g_g.nil?
        ce.with_verbatim_data_georeference = true
        ce.generate_verbatim_data_georeference(true) if ce.with_verbatim_data_georeference
      end
      unless ce.id == 167457
        ce.save!
      end
    end
    skip_record
      # redirect_to(collecting_event_lat_long_task_path(collecting_event_id: next_record))
    # redirect_to(lat_long_skip_record_path(collecting_event_id: next_record))
  end

  def next_record
    CollectingEvent.with_project_id(sessions_current_project_id).where('id > ?', collecting_event_id_param).limit(1).pluck(:id)[0]
  end

  def skip_record
    redirect_to(collecting_event_lat_long_task_path(collecting_event_id: next_record))
  end

  def similar_labels
    @similar_labels = CollectingEvent.where('id > ?', next_record).limit(5)
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
    params.permit(:verbatim_latitude, :verbatim_longitude, :collecting_event_id, :gen_georef_box)
  end

end
