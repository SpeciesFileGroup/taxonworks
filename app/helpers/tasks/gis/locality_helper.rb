module Tasks::Gis::LocalityHelper

  # @param [integer] distance (in meters)
  def collecting_events_nearby(distance)
    @collecting_events = @collecting_event.find_others_within_radius_of(distance)
  end

  def collecting_event_georeference_count(collecting_event)
    count = collecting_event.georeferences.count
    if count > 0
      count.to_s
    else
      'none'
    end
  end

  def distance_from(collecting_event)
    collecting_event.distance_to(collecting_event.geographic_items.first)
  end

end
