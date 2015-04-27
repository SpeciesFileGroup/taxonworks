class Tasks::Gis::MatchGeoreferenceController < ApplicationController

  def index
    # some things on to which to hang one's hat.
    @collecting_event  = CollectingEvent.new
    @georeference      = Georeference.new
    @collecting_events = CollectingEvent.where(verbatim_label: 'nothing')
    @georeferences     = Georeference.where(type: 'bologna')
  end

  # NOT TESTED, but something like 
  def filtered_collecting_events
    @motion            = 'filtered_collecting_events'
    @collecting_events = [] # replace [] with CollectingEvent.filter(params)
    render_ce_select_json
  end

  def recent_collecting_events
    @motion            = 'recent_collecting_events'
    how_many           = params['how_many']
    @collecting_events = CollectingEvent.where(project_id: $project_id).order(updated_at: :desc).limit(how_many.to_i)
    render_ce_select_json
  end

  def tagged_collecting_events
    @motion = 'tagged_collecting_events'
    # step_1             = ControlledVocabularyTerm.where("type = 'Keyword' and name like \'%#{params['what_keyword']}%\'").pluck(:id)
    # step_2 = Tag.where('tag_object_type = \'CollectingEvent\' and (keyword_id in (?))', step_1).pluck(:tag_object_id).uniq
    # @collecting_events = CollectingEvent.where(project_id: $project_id).order(updated_at: :desc).where('id in (?)', step_2)
    # render_ce_select_json

    if params[:keyword_id]
      keyword            = Keyword.find(params[:keyword_id])
      @collecting_events = CollectingEvent.where(project_id: $project_id).order(updated_at: :desc).tagged_with_keyword(keyword)
      render_ce_select_json
    else
      # You have to figure out how to catch a bad search request and return not a list but back to the form
      render json: {html: 'Empty set'} #and return
    end

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
    how_many       = params['how_many']
    @georeferences = Georeference.where(project_id: $project_id).order(updated_at: :desc).limit(how_many.to_i)
    render_gr_select_json
  end

  def tagged_georeferences
    @motion            = 'tagged_georeferences'
    @georeferences = [] # replace [] with CollectingEvent.filter(params)
    render_ce_select_json
  end

  def drawn_georeferences
    @motion            = 'drawn_georeferences'
    @georeferences = [] # replace [] with CollectingEvent.filter(params)
    render_gr_select_json
  end

  def batch_create
    count = Georeference.batch_create_from_georeference_matcher(params)
    if count > 0
      render json: {html: "There #{pluralize(count 'was', 'were')} #{count} #{pluralize(count, 'georeference')} created"}
    end

  end

  # @return [JSON] with html for collecting events display (table of selectable collecting events)
  def render_ce_select_json
    # retval = render_to_html
    retval = render json: {html: ce_render_to_html}
    retval
  end

  # @return [JSON] with html for georeferences display (feature collection)
  def render_gr_select_json
    retval = render json: {html: gr_render_to_html}
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
