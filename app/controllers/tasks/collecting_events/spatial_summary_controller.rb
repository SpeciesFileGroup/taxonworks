class Tasks::CollectingEvents::SpatialSummaryController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @collecting_events = Queries::CollectingEvent::Filter.new(params)
  end

end
