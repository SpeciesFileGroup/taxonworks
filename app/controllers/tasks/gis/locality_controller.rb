class Tasks::Gis::LocalityController < ApplicationController
  include TaskControllerConfiguration

  def nearby
    # @nearby_distance = 5000
    @related_routes   = UserTasks.related_routes('nearby_locality_task')
    @collecting_event = CollectingEvent.find(params[:id])

    @nearby_distance   = Utilities::Geo.nearby_from_params(params)
    @collecting_events = @collecting_event.find_others_within_radius_of(@nearby_distance)
  end

  def update
    params['nearby_distance'] = (params['digit1'].to_i * params['digit2'].to_i).to_s
    nearby
  end

  def within
    @related_routes    = UserTasks.related_routes('nearby_locality_task')
    @geographic_item   = GeographicItem.find(params[:id])
    @collecting_events = CollectingEvent.find_others_contained_within(@geographic_item)
  end

  # @return [Scope] Preload an empty set of collecting events
  def new_list
    @collecting_events = CollectingEvent.where('false')
  end

  # use the params[:geographic_area_id] to locate the area, use that to find a geographic
  def list
    @geographic_area = GeographicArea.find(params[:geographic_area_id])
    case params[:commit]
      when 'Show'
        if @geographic_area.has_shape?
          @collecting_events = CollectingEvent.find_others_contained_within(@geographic_area.default_geographic_item)
                                 .order(:verbatim_locality)
                                 .select(:id)
        else
          @collecting_events = CollectingEvent.where('false')
        end
      # gather_list_data(@geographic_item)
      else
    end
  end

  def gather_list_data(geographic_area)
    if @geographic_area.has_shape?
      @geographic_item = @geographic_area.default_geographic_item
    else
      @geographic_item = nil
    end
  end

end
