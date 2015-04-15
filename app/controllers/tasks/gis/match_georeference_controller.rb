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
    render_ce_select
  end

  def recent_collecting_events
    @motion            = 'recent_collecting_events'
    @collecting_events = [] # replace [] with CollectingEvent.filter(params)
    render_ce_select
  end

  def tagged_collecting_events
    @motion            = 'tagged_collecting_events'
    @collecting_events = [] # replace [] with CollectingEvent.filter(params)
    render_ce_select
  end

  def drawn_collecting_events
    @motion            = 'drawn_collecting_events'
    @collecting_events = [] # replace [] with CollectingEvent.filter(params)
    render_ce_select
  end

  def filtered_georeferences
    @motion            = 'filtered_georeference'
    @collecting_events = [] # replace [] with CollectingEvent.filter(params)
    render_ce_select
  end

  def recent_georeferences
    @motion            = 'recent_georeferences'
    @collecting_events = [] # replace [] with CollectingEvent.filter(params)
    render_ce_select
  end

  def tagged_georeferences
    @motion            = 'tagged_georeferences'
    @collecting_events = [] # replace [] with CollectingEvent.filter(params)
    render_ce_select
  end

  def drawn_georeferences
    @motion            = 'drawn_georeferences'
    @collecting_events = [] # replace [] with CollectingEvent.filter(params)
    render_ce_select
  end

  def batch_create
    count = Georeference.batch_create_from_georeference_matcher(params)
    if count > 0
      render json: {html: "There #{pluralize(count 'was', 'were')} #{count} #{pluralize(count, 'georeference')} created"}
    end

  end

  # @return [JSON]
  def render_ce_select
    render json: {
             html: render_to_string(partial: 'tasks/gis/match_georeference/collecting_event_selections',
                                    locals:  {collecting_events: @collecting_events,
                                              motion:            @motion})
           }
  end
end
