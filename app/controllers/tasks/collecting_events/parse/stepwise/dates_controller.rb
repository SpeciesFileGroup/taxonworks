class Tasks::CollectingEvents::Parse::Stepwise::DatesController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @filters = parse_filters(params)
    @collecting_event = current_collecting_event
    if @collecting_event.nil?
      flash['notice'] = 'No collecting events with parsable records found.'
      redirect_to hub_path and return
    end
    @matching_items = []
  end

  def parse_filters(params)
    # default filter is is all filters
    if params['filters'].blank?
      Utilities::Dates::REGEXP_DATES.keys
    else
      params.permit(filters: [])[:filters].map(&:to_sym)
    end
  end

  def skip
    redirect_to dates_index_task_path(collecting_event_id: next_collecting_event_id,
                                      filters: parse_filters(params))
  end

  # POST
  def update
    next_id = next_collecting_event_id
    ce = current_collecting_event
    any_failed = false
    # if ce.update_attributes(collecting_event_params)
    start_date = convert_params[:start_date].split(' ')
    end_date = convert_params[:end_date].split(' ')
    start_date_year = start_date[0]
    start_date_month = start_date[1]
    start_date_day = start_date[2]
    end_date_year = end_date[0]
    end_date_month = end_date[1]
    end_date_day = end_date[2]
    if ce.update_attributes({start_date_year: start_date[0],
                             start_date_month: start_date[1],
                             start_date_day: start_date[2],
                             end_date_year: end_date[0],
                             end_date_month: end_date[1],
                             end_date_day: end_date[2],
                             verbatim_date: convert_params['verbatim_date']
                            })
    else
      any_failed = true
      message = 'Failed to update the collecting event.'
    end

    if any_failed
      flash['alert'] = message
      next_id = current_collecting_event.id
    else # a.k.a. success
      flash['notice'] = 'Updated.'
    end
    # where do we go from here?
    redirect_to dates_index_task_path(collecting_event_id: next_id,
                                      filters: parse_filters(params))
  end

  # all buttons come here, so we first have to look at the button value
  def save_selected
    next_id = next_collecting_event_id
    selected = params[:selected]
    if selected.blank?
      message = 'Nothing to save.'
      success = false
    else
      any_failed = false
      selected.each {|item_id|
        ce = CollectingEvent.find(item_id)
        unless ce.nil?
          start_date = convert_params[:start_date].split(' ')
          end_date = convert_params[:end_date].split(' ')
          start_date_year = start_date[0]
          start_date_month = start_date[1]
          start_date_day = start_date[2]
          end_date_year = end_date[0]
          end_date_month = end_date[1]
          end_date_day = end_date[2]
          if ce.update_attributes({start_date_year: start_date[0],
                                   start_date_month: start_date[1],
                                   start_date_day: start_date[2],
                                   end_date_year: end_date[0],
                                   end_date_month: end_date[1],
                                   end_date_day: end_date[2],
                                   verbatim_date: convert_params['verbatim_date']
                                  })
          else
            any_failed = true
            message = 'one or more of the collecting events.'
          end
        end
      }
      success = any_failed ? false : true
    end
    if success
      flash['notice'] = 'Updated.' # unless no_flash # if we skipped, there is no flash
    else
      flash['alert'] = message
      next_id = current_collecting_event.id
    end
    # where do we go from here?
    redirect_to dates_index_task_path(collecting_event_id: next_id,
                                      filters: parse_filters(params))
  end

  def convert
    retval = {}
    render json: retval
  end

  def similar_labels
    retval = {}
    start_date = similar_params[:start_date]
    end_date = similar_params[:end_date]
    piece = similar_params[:piece]
    collecting_event_id = similar_params[:collecting_event_id]
    include_values = (similar_params[:include_values].nil?) ? false : true
    method = [similar_params[:method].to_sym]
    where_clause = regex_on_data(piece)
    where_clause += ' and (verbatim_date is null)' unless include_values
    if method[0] == :undefined # where verbatim label is entered without selecting a result and its method
      selected_items = CollectingEvent.where(where_clause)
                           .with_project_id(sessions_current_project_id)
                           .order(:id)
                           .where.not(id: collecting_event_id).distinct
    else
      selected_items = Queries::CollectingEventDatesExtractorQuery.new(
          collecting_event_id: nil,
          filters: method)
                           .all
                           .with_project_id(sessions_current_project_id)
                           .order(:id)
                           .where.not(id: collecting_event_id)
                           .where(where_clause).distinct
    end

    retval[:count] = selected_items.count.to_s
    retval[:table] = render_to_string(partial: 'make_dates_matching_table',
                                      locals: {
                                          piece: piece,
                                          start_date: start_date,
                                          end_date: end_date,
                                          selected_items: selected_items
                                      })
    render(json: retval)
  end

  protected

  def regex_on_data(match_data_0)
    # retval = "verbatim_label ~* '(\\D#{sql_fix_tix(match_data_0)}\\D)'" ### originally. but replaced below
    retval = "verbatim_label ~ '(\\A#{sql_fix_tix(match_data_0)}\\D)|(\\D#{sql_fix_tix(match_data_0)}\\D)|(\\D#{sql_fix_tix(match_data_0)}\\Z)|(\\A#{sql_fix_tix(match_data_0)}\\Z)'"
  end

  def sql_fix_tix(item)
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
      retval = Queries::CollectingEventDatesExtractorQuery.new(
          collecting_event_id: nil,
          filters: parse_filters(params))
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
    Queries::CollectingEventDatesExtractorQuery.new(
        collecting_event_id: collecting_event_id_param,
        filters: filters)
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

  def similar_params
    params.permit(:include_values, :piece, :start_date, :end_date, :method, :collecting_event_id)
  end

  def collecting_event_params
    # params.require(:collecting_event).permit(:verbatim_date, :start_date_day, :start_date_month, :start_date_year, :end_date_day, :end_date_month, :end_date_year)
    params.permit(:verbatim_date, :piece, :start_date, :end_date)
  end

  def convert_params
    params.permit(:include_values, :verbatim_date, :piece, :start_date, :end_date)
  end

end