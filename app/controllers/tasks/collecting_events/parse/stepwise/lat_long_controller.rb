class Tasks::CollectingEvents::Parse::Stepwise::LatLongController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @collecting_events = Queries::CollectingEventLatLongExtractorQuery
                           .new(collecting_event_id: 968,
                                project_id:          sessions_current_project_id,
                                filters:             [:dd, :d_dm]).all.limit(5)
    # defaults to first found
    @collecting_events
  end

  def similar_label
    @similar_labels = CollectingEvent.where('id > 969')
  end

end
