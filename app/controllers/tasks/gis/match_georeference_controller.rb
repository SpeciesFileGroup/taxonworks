class Tasks::Gis::MatchGeoreferenceController < ApplicationController

  def index
    # some things on to which to hang one's hat.
    @collecting_event  = CollectingEvent.new
    @georeference      = Georeference.new
    @collecting_events = CollectingEvent.where(verbatim_label: 'nothing')
    @georeferences     = Georeference.where(type: 'bologna')
  end

  def filtered_collecting_events
    @motion            = 'filtered_collecting_events'
    @collecting_events = [] # replace [] with CollectingEvent.filter(params)
    render_ce_select_json
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
end
