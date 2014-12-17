class Tasks::Gis::LocalityController < ApplicationController
  include TaskControllerConfiguration

  def nearby
    @collecting_event = CollectingEvent.find(params[:id])
  end

end
