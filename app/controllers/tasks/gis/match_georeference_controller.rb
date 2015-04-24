class Tasks::Gis::MatchGeoreferenceController < ApplicationController

  def index
    # some things on to which to hang one's hat.
    @collecting_event  = CollectingEvent.new
    @georeference      = Georeference.new
    @collecting_events = CollectingEvent.where(verbatim_label: 'nothing')
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
    @motion            = 'tagged_collecting_events'
    # step_1 = Tag.find_for_autocomplete(term: params['what_keyword'])
    step_1             = ControlledVocabularyTerm.where("type = 'Keyword' and name like \'%#{params['what_keyword']}%\'").pluck(:id)
    step_2 = Tag.where('tag_object_type = \'CollectingEvent\' and (keyword_id in (?))', step_1).pluck(:tag_object_id).uniq
    @collecting_events = CollectingEvent.where(project_id: $project_id).order(updated_at: :desc).where('id in (?)', step_2)
    render_ce_select_json

    if params[:keyword_id] 
      keyword = Keyword.find(params[:keyword_id])
      @collecting_events = CollectingEvent.where(project_id: $project_id).order(updated_at: :desc).tagged_with_keyword(keyword)
      render_ce_select_json
    else
      # You have to figure out how to catch a bad search request and return not a list but back to the form
      render json: {} and return
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
    @motion            = 'recent_georeferences'
    @collecting_events = [] # replace [] with CollectingEvent.filter(params)
    render_ce_select_json
  end

  def tagged_georeferences
    @motion            = 'tagged_georeferences'
    @collecting_events = [] # replace [] with CollectingEvent.filter(params)
    render_ce_select_json
  end

  def drawn_georeferences
    @motion            = 'drawn_georeferences'
    @collecting_events = [] # replace [] with CollectingEvent.filter(params)
    render_cr_select_json
  end

  def batch_create
    count = Georeference.batch_create_from_georeference_matcher(params)
    if count > 0
      render json: {html: "There #{pluralize(count 'was', 'were')} #{count} #{pluralize(count, 'georeference')} created"}
    end

  end

  # @return [JSON]
  def render_ce_select_json
    # retval = render_to_html
    retval = render json: {html: render_to_html}
    retval
  end

  def render_gr_select_json
    render json: {html: render_to_html}   # not really, render geojson feature collection
  end

  # @return [String] of html for partial
  def render_to_html
    render_to_string(partial: 'tasks/gis/match_georeference/collecting_event_selections',
                     locals:  {collecting_events: @collecting_events,
                               # locals:            {token: form_authenticity_token},
                               motion:            @motion})
  end
end
