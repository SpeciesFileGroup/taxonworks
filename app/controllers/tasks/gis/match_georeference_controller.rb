class Tasks::Gis::MatchGeoreferenceController < ApplicationController

  def index
    # something to hang one's hat on
    @collecting_event = CollectingEvent.new
    @georeference = Georeference.new
  end

  def filtered_collecting_events
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
