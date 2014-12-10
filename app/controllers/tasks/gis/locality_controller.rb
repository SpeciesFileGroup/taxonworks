class Tasks::Gis::LocalityController < ApplicationController
  include TaskControllerConfiguration

  def nearby
    @collecting_event = CollectingEvent.find(params[:id])
  end

  def nearby_link(collecting_event)
    return nil if collecting_event.nil?
    link_to('nearby', collecting_event)
  end

end
