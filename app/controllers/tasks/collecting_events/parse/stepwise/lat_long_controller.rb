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

  # all buttons come here, so we first have to look at the button value
  def process_buttons
    prevention = ['39605', '103244', '57187', '103255']
    no_flash = false
    success    = false
    message    = 'Failed to update '
    next_id  = next_collecting_event_id
    case params['button']
      when 'select_all', 'deselect_all'
        raise '\'select_all\', and \'deselect_all\' should be preempted by javascript'
      when 'skip'
        success  = true # slide right along
        no_flash = true # don't need no stinkin' flashes
      when 'save_selected'
        selected = params[:selected]
        unless selected.blank?
          selected.each { |item_id|
            ce = CollectingEvent.find(item_id)
            unless ce.nil?
              unless prevention.include?(params[:collecting_event_id])
                if ce.update_attributes(collecting_event_params)
                  ce.generate_verbatim_data_georeference(true) if generate_georeference?
                  success = true
                else
                  message += 'one or more of the collecting events.'
                end
              end
            end
          }
        end
      when 'save_one'
        unless prevention.include?(params[:collecting_event_id])
          if current_collecting_event.update_attributes(collecting_event_params)
            current_collecting_event.generate_verbatim_data_georeference(true) if generate_georeference?
            success = true
          end
        end
        message += 'the collecting event.'
    end

    if success
      flash['notice'] = 'Updated.' unless no_flash # if we skipped, there is no flash
    else
      flash['alert'] = message
      next_id        = current_collecting_event.id
    end
    # where do we go from here?
    redirect_to collecting_event_lat_long_task_path(collecting_event_id: next_id,
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
    retval         = {}
    lat            = collecting_event_params[:lat]
    long           = collecting_event_params[:long]
    piece          = collecting_event_params[:piece]
    # collecting_event_id = collecting_event_params[:collecting_event_id]
    include_values = (collecting_event_params[:include_values].nil?) ? false : true
    sql_1          = '('
    sql_1          += "verbatim_label LIKE '%#{sql_fix(lat)}%'" unless lat.blank?
    sql_1          += " or verbatim_label LIKE '%#{sql_fix(long)}%'" unless long.blank?
    sql_1          += " or verbatim_label LIKE '%#{sql_fix(piece)}%'" unless piece.blank?
    sql_1          += ')'
    sql_1          += ' and (verbatim_latitude is null or verbatim_longitude is null)' unless include_values
    selected_items = CollectingEvent.where(sql_1)
                       .with_project_id(sessions_current_project_id)
                       .order(:id)
                       .where.not(id: params[:collecting_event_id]).distinct

    retval[:count] = selected_items.count.to_s
    retval[:table] = render_to_string(partial: 'matching_table',
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
    retval = nil
    begin
      retval = params.require(:collecting_event_id)
    rescue ActionController::ParameterMissing
      # nothing provided, get the first possible one
      # return CollectingEvent.with_project_id(sessions_current_project_id).order(:id).limit(1).pluck(:id)[0]
      retval = Queries::CollectingEventLatLongExtractorQuery.new(
        collecting_event_id: nil,
        filters:             parse_filters(params))
                 .all
                 .with_project_id(sessions_current_project_id)
                 .order(:id)
                 .limit(1)
                 .pluck(:id)[0]
    end
    retval
  end

  # TODO: deprecate for valud from view/helper
  def next_collecting_event_id
    filters = parse_filters(params)
    Queries::CollectingEventLatLongExtractorQuery.new(
      collecting_event_id: collecting_event_id_param,
      filters:             filters)
      .all
      .with_project_id(sessions_current_project_id)
      .order(:id)
      .limit(1)
      .pluck(:id)[0]
  end

  def current_collecting_event
    finding = collecting_event_id_param
    if finding.nil?
      CollectingEvent.first
    else
      CollectingEvent.find(finding)
    end
  end

  def process_params
    params.permit(:matched_ids, :button, :matched_latitude, :matched_longitude, selected: [])
  end

  def matched_params
    retval = {
      verbatim_latitude:     process_params[:matched_latitude],
      verbatim_longitude:    process_params[:matched_longitude],
      generate_georeference: process_params[:match_gen_georeference]
    }
    retval
  end

  def collecting_event_params
    params.permit(:include_values, :verbatim_latitude, :verbatim_longitude, :piece, :lat, :long)
  end

  def generate_georeference?
    params[:generate_georeference].blank? ? false : true
  end
end
