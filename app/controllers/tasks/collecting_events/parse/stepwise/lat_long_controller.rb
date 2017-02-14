class Tasks::CollectingEvents::Parse::Stepwise::LatLongController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @collecting_event = CollectionEvent.next_need_parse
  end

end
