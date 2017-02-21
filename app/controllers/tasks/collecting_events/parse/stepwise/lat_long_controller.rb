class Tasks::CollectingEvents::Parse::Stepwise::LatLongController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @collecting_events = Queries::CollectingEventLatLongExtractorQuery.new(collecting_event_id: nil,
                                                                           filters:             [:dd]).all.limit(5)
    # defaults to first found
    @collecting_events
  end

end
