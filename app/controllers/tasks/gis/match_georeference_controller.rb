class Tasks::Gis::MatchGeoreferenceController < ApplicationController

  def index
    # some things on to which to hang one's hat.
    @collecting_event  = CollectingEvent.new
    @georeference      = Georeference.new
    @collecting_events = []
    @georeferences     = []
  end

  def filtered_collecting_events
    @motion    = 'filtered_collecting_events'
    message    = ''
    start_time = fix_time(params['start_date_year'],
                          params['start_date_month'],
                          params['start_date_day'])
    end_time   = fix_time(params['end_date_year'],
                          params['end_date_month'],
                          params['end_date_day'])
    if end_time == start_time
      end_time = Time.now
    end
    st_year, st_month, st_day    = params['start_date_year'], params['start_date_month'], params['start_date_day']
    end_year, end_month, end_day = params['end_date_year'], params['end_date_month'], params['end_date_day']
    v_locality_fragment          = params['verbatim_locality_text']
    any_label_fragment           = params['any_label_text']
    id_fragment                  = params['identifier_text']
    unless st_year.blank? and end_year.blank and st_month.blank? and end_month.blank? and st_day.blank? and end_day.blank?
      sql_string = "(start_date_year is not null and start_date_year between #{st_year} and #{end_year})"
      sql_string += " or (end_date_year is not null and end_date_year between #{st_year} and #{end_year})"
    end
    # sql_string += "(end_date_year is not null and end_date_year between #{start_time.year} and #{end_time.year})"
    unless v_locality_fragment.blank?
      sql_string += " or verbatim_locality ilike '%#{v_locality_fragment}%'"
    end
    unless any_label_fragment.blank?
      sql_string += " or (verbatim_label ilike '%#{any_label_fragment}%'"
      sql_string += " or print_label ilike '%#{any_label_fragment}%'"
      sql_string += " or document_label ilike '%#{any_label_fragment}%'"
      sql_string += ')'
    end
    @collecting_events = CollectingEvent.where(sql_string).uniq

    if @collecting_events.length == 0
      message = 'no collecting events selected'
    end
    render_ce_select_json(message)
  end

  def recent_collecting_events
    @motion            = 'recent_collecting_events'
    message            = ''
    how_many           = params['how_many']
    @collecting_events = CollectingEvent.where(project_id: $project_id).order(updated_at: :desc).limit(how_many.to_i)
    if @collecting_events.length == 0
    else
      message = 'no recent objects selected'
    end
    render_ce_select_json(message)
  end

  def tagged_collecting_events
    @motion = 'tagged_collecting_events'
    message = ''
    if params[:keyword_id]
      keyword            = Keyword.find(params[:keyword_id])
      @collecting_events = CollectingEvent.where(project_id: $project_id).order(updated_at: :desc).tagged_with_keyword(keyword)
    else
      # You have to figure out how to catch a bad search request and return not a list but back to the form
      message = 'no tagged objects selected' #and return
    end
    render_ce_select_json(message)
  end

  def drawn_collecting_events
    @motion            = 'drawn_collecting_events'
    @collecting_events = [] # replace [] with CollectingEvent.filter(params)
    render_ce_select_json
  end

  def filtered_georeferences
    @motion            = 'filtered_georeference'
    @collecting_events = [] # replace [] with CollectingEvent.filter(params)
    render_ce_select_json
  end

  def recent_georeferences
    @motion        = 'recent_georeferences'
    message        = ''
    how_many       = params['how_many']
    @georeferences = Georeference.where(project_id: $project_id).order(updated_at: :desc).limit(how_many.to_i)
    if @georeferences.length == 0
      message = 'no recent georeferences selected'
    end
    render_gr_select_json(message)
  end

  def tagged_georeferences
    @motion = 'tagged_georeferences'
    message = ''

    # todo: this needs to be rationalized, but works, after a fashion.
    if params[:keyword_id].blank?
      # render json: {html: 'Empty set'} #and return
      @georeferences = []
      message        = 'no tagged objects selected'
    else
      keyword        = Keyword.find(params[:keyword_id])
      @georeferences = CollectingEvent.where(project_id: $project_id).order(updated_at: :desc).tagged_with_keyword(keyword).map(&:georeferences).to_a.flatten
    end
    render_gr_select_json(message)
  end

  def drawn_georeferences
    @motion        = 'drawn_georeferences'
    @georeferences = [] # replace [] with CollectingEvent.filter(params)
    render_gr_select_json
  end

  def batch_create
    count = Georeference.batch_create_from_georeference_matcher(params)
    if count > 0
      render json: {html: "There #{pluralize(count 'was', 'were')} #{count} #{pluralize(count, 'georeference')} created"}
    end

  end

  # @param [String] message to be conveyed to client side
  # @return [JSON] with html for collecting events display (table of selectable collecting events)
  def render_ce_select_json(message = '')
    # retval = render_to_html
    retval = render json: {message: message, html: ce_render_to_html}
    retval
  end

  # @param [String] message to be conveyed to client side
  # @return [JSON] with html for georeferences display (feature collection)
  def render_gr_select_json(message = '')
    retval = render json: {message: message, html: gr_render_to_html}
    retval
  end

  # @return [String] of html for partial
  def ce_render_to_html
    render_to_string(partial: 'tasks/gis/match_georeference/collecting_event_selections',
                     locals:  {collecting_events: @collecting_events,
                               motion:            @motion})
  end

  # @return [String] of html for partial
  def gr_render_to_html
    render_to_string(partial: 'tasks/gis/match_georeference/georeferences_selections_form',
                     locals:  {georeferences: @georeferences,
                               motion:        @motion})
  end

  def fix_time(year, month, day)
    start = Time.new(1970, 1, 1)
    if year.blank?
      year = start.year
    end
    if month.blank?
      month = start.month
    end
    if day.blank?
      day = start.day
    end
    Time.new(year, month, day)
  end
end
