class Tasks::CollectingEvents::Parse::Stepwise::LatLongController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @filters          = parse_filters(params)
    @collecting_event = current_collecting_event
    if @collecting_event.nil?
      flash['notice'] = 'No collecting events with parsable records found.'
      redirect_to hub_path and return
    end
    @matching_items = []
  end

  # GET
  def skip
    # where do we go from here?
    redirect_to collecting_event_lat_long_task_path(collecting_event_id: next_collecting_event_id,
                                                    filters:             parse_filters(params))
  end

  # GET
  def re_eval
    # where do we go from here?
    redirect_to collecting_event_lat_long_task_path(collecting_event_id: current_collecting_event.id,
                                                    filters:             parse_filters(params))
  end

  # GET
  def save_selected
    selected = params[:selected]
    next_id  = next_collecting_event_id
    if selected.blank?
      message = 'Nothing to save.'
      success = false
    else
      any_failed = false
      message    = 'Success'
      selected.each { |item_id|
        ce = CollectingEvent.find(item_id)
        unless ce.nil?
          if ce.update_attributes(collecting_event_params)
            ce.generate_verbatim_data_georeference(true) if generate_georeference?
          else
            any_failed = true
            message    += 'Failed to update one or more of the collecting events.'
          end
        end
      }
      success = any_failed ? false : true
    end
    if success
      flash['notice'] = 'Updated.'
    else
      flash['alert'] = message
      next_id        = current_collecting_event.id
    end
    # where do we go from here?
    redirect_to collecting_event_lat_long_task_path(collecting_event_id: next_id,
                                                    filters:             parse_filters(params))
  end

  # POST
  def update
    next_id = next_collecting_event_id
    ce      = current_collecting_event
    success = false
    if ce.update_attributes(collecting_event_params)
      ce.generate_verbatim_data_georeference(true) if generate_georeference?
      success = true
    end
    message = 'Failed to update the collecting event.'

    if success
      flash['notice'] = 'Updated.'
    else
      flash['alert'] = message
      next_id        = current_collecting_event.id
    end
    # where do we go from here?
    redirect_to collecting_event_lat_long_task_path(collecting_event_id: next_id,
                                                    filters:             parse_filters(params))
  end

  # GET
  def convert
    lat                 = convert_params[:verbatim_latitude]
    long                = convert_params[:verbatim_longitude]
    retval              = {}
    retval[:lat_piece]  = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(lat)
    retval[:long_piece] = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(long)
    render json: retval
  end

  # GET
  def similar_labels
    retval         = {}
    lat            = similar_params[:lat]
    long           = similar_params[:long]
    piece          = similar_params[:piece]
    include_values = (similar_params[:include_values].nil?) ? false : true
    ce             = CollectingEvent.find(similar_params[:collecting_event_id])
    selected_items = ce.similar_lat_longs(lat, long, sessions_current_project_id, piece, include_values)

    retval[:count] = selected_items.count.to_s
    retval[:table] = render_to_string(partial: 'lat_long_matching_table',
                                      locals:  {
                                        lat:            lat,
                                        long:           long,
                                        selected_items: selected_items
                                      }) #([lat, long], selected_items)
    render(json: retval)
  end

  protected

  def collecting_event_id_param
    retval = nil
    begin
      retval = params.require(:collecting_event_id)
    rescue ActionController::ParameterMissing
      # nothing provided, get the first possible one
      # return CollectingEvent.with_project_id(sessions_current_project_id).order(:id).limit(1).pluck(:id)[0]
      retval = Queries::CollectingEventLatLongExtractorQuery.new(collecting_event_id: nil,
                                                                 filters:             parse_filters(params))
                 .all
                 .with_project_id(sessions_current_project_id)
                 .order(:id)
                 .limit(1)
                 .pluck(:id)[0]
    end
    retval
  end

  def next_collecting_event_id
    retval = Queries::CollectingEventLatLongExtractorQuery.new(collecting_event_id: collecting_event_id_param,
                                                               filters:             parse_filters(params))
               .all
               .with_project_id(sessions_current_project_id)
               .order(:id)
               .limit(1)
               .pluck(:id)[0]
    retval
  end

  def current_collecting_event
    finding = collecting_event_id_param
    finding.nil? ? CollectingEvent.first : CollectingEvent.find(finding)
  end

  def similar_params
    params.permit(:collecting_event_id, :include_values, :piece, :lat, :long)
  end

  # default filter set is all filters
  def parse_filters(params)
    if params['filters'].blank?
      Utilities::Geo::REGEXP_COORD.keys
    else
      params.permit(filters: [])[:filters].map(&:to_sym)
    end
  end

  def collecting_event_params
    params.permit(:verbatim_latitude, :verbatim_longitude)
  end

  def convert_params
    params.permit(:include_values, :verbatim_latitude, :verbatim_longitude, :piece, :lat, :long)
  end

  def generate_georeference?
    params[:generate_georeference].blank? ? false : true
  end
end
