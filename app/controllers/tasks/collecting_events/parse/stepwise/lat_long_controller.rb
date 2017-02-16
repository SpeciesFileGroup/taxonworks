class Tasks::CollectingEvents::Parse::Stepwise::LatLongController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @collecting_event = CollectingEvent.next_needs_parse(params[:next_record]) # defaults to first found
    @collecting_event
  end

end
