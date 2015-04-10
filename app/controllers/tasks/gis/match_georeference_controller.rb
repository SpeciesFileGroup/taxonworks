class Tasks::Gis::MatchGeoreferenceController < ApplicationController

  def index
    # some things on to which to hang one's hat.
    @collecting_event  = CollectingEvent.new
    @georeference      = Georeference.new
    @collecting_events = CollectingEvent.where(verbatim_label: 'nothing')
  end

  # NOT TESTED, but something like 
  def filtered_collecting_events
    @motion = 'filtered_collecting_event'
    # redirect_to(:back)

    @collecting_events = [] # replace [] with CollectingEvent.filter(params)

    render json: {
      html: render_to_string(partial: 'tasks/gis/match_georeference/collecting_event_selections', locals: { collecting_events: @colleting_events } )
    }
    # and
#    and
  end

  def recent_collecting_events
  end

  def tagged_collecting_events
  end

  def drawn_collecting_events
  end

  def filtered_georeferences
  end

  def recent_georeferences
  end

  def tagged_georeferences
  end

  def drawn_georeferences
  end
end
