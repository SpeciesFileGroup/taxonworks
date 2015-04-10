class Tasks::Gis::MatchGeoreferenceController < ApplicationController

  def index
    # some things on to which to hang one's hat.
    @collecting_event  = CollectingEvent.new
    @georeference      = Georeference.new
    @collecting_events = CollectingEvent.where(verbatim_label: 'nothing')
  end

  def filtered_collecting_events
    redirect_to(match_georeference_task_path)
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
