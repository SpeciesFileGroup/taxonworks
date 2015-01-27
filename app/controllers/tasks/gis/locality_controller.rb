class Tasks::Gis::LocalityController < ApplicationController
  include TaskControllerConfiguration

  def nearby
    # @nearby_distance = 5000
    @related_routes = UserTasks.related_routes('nearby_locality_task') 
    @collecting_event = CollectingEvent.find(params[:id])

    @nearby_distance = Utilities::Geo.nearby_from_params(params) 
    @collecting_events = @collecting_event.find_others_within_radius_of(@nearby_distance)
  end

  def update
    params['nearby_distance'] = (params['digit1'].to_i * params['digit2'].to_i).to_s
    nearby
  end

  def within
    @related_routes = UserTasks.related_routes('nearby_locality_task')
    @geographic_item = GeographicItem.find(params[:id])
    @collecting_events = CollectingEvent.find_others_contained_within(@geographic_item)
  end

end
