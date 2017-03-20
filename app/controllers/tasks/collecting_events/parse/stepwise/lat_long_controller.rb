DEFAULT_SQL_REGEXS = []
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
    @matching_items   = []
  end

  def parse_filters(params)
    # default filter is is all filters
    if params['filters'].blank?
      Utilities::Geo::REGEXP_COORD.keys
    else
      params.permit(filters: [])[:filters].map(&:to_sym)
    end
    # filters = []
    # params.keys.each { |kee|
    #   if kee.start_with?('select_')
    #     filters.push(kee.gsub('select_', '').downcase.to_sym)
    #   end
    # }
    # filters
  end

  # both  the Skip and the Show buttons come here, so we first have to look at the button value
  def update
    case params['button']
      when 'skip'
      else
        if current_collecting_event.update_attributes(collecting_event_params)
          collecting_event.generate_verbatim_data_georeference(true) if generate_georeference?
          flash['notice'] = 'Updated.'
        else
          flash['alert'] = 'Failed to update the collecting event.'
          redirect_to collecting_event_lat_long_task_path(collecting_event_id: current_collecting_event.id) and return
        end

    end
    # TODO: pass in next as determined in view
    redirect_to collecting_event_lat_long_task_path(collecting_event_id: next_collecting_event_id,
                                                    filters:             parse_filters(params))
  end

  def convert
    lat                 = collecting_event_params[:verbatim_latitude]
    long                = collecting_event_params[:verbatim_longitude]
    retval              = {}
    retval[:lat_piece]  = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(lat)
    retval[:long_piece] = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(long)
    render json: retval
  end

  def similar_labels
    retval              = {}
    lat                 = collecting_event_params[:lat]
    long                = collecting_event_params[:long]
    piece               = collecting_event_params[:piece]
    collecting_event_id = collecting_event_params[:collecting_event_id]
    include_values      = (collecting_event_params[:include_values].nil?) ? false : true
    sql_1          = "(verbatim_label LIKE '%#{sql_fix(lat)}%' or verbatim_label LIKE '%#{sql_fix(long)}%'"
    sql_1          += " or verbatim_label LIKE '%#{sql_fix(piece)}%')"
    sql_1          += ' and (verbatim_latitude is null or verbatim_longitude is null)' unless include_values
    selected_items = CollectingEvent.where(sql_1)
                       .with_project_id(sessions_current_project_id)
                       .where.not(id: collecting_event_id).distinct

    retval[:count]      = selected_items.count.to_s
    retval[:table]      = render_to_string(partial: 'matching_table',
                                           locals:  {
                                             lat:            lat,
                                             long:           long,
                                             selected_items: selected_items
                                           }) #([lat, long], selected_items)
    render(json: retval)
  end

  protected
  def sql_fix(item)
    retval = item.gsub("'", "''")
    retval
  end

  def collecting_event_id_param
    begin
      this_id = params.require(:collecting_event_id)
      return Queries::CollectingEventLatLongExtractorQuery.new(
        collecting_event_id: this_id,
        filters:             parse_filters(params))
               .all
               .with_project_id(sessions_current_project_id)
               .order(:id)
               .limit(1)
               .pluck(:id)[0]
    rescue ActionController::ParameterMissing
      # nothing provided, get the first possible one
      return CollectingEvent.with_project_id(sessions_current_project_id).order(:id).limit(1).pluck(:id)[0]
    end
  end

  # TODO: deprecate for valud from view/helper
  def next_collecting_event_id
    filters = parse_filters(params)
    Queries::CollectingEventLatLongExtractorQuery.new(
      collecting_event_id: collecting_event_id_param,
      filters:             filters).all.with_project_id(sessions_current_project_id).first.id
  end

  def current_collecting_event
    CollectingEvent.find(collecting_event_id_param)
  end

  def collecting_event_params
    params.permit(:include_values, :collecting_event_id, :verbatim_latitude, :verbatim_longitude, :piece, :lat, :long)
  end

  def generate_georeference?
    !params[:generate_georeference].blank?
  end

end
