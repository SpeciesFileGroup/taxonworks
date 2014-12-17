module Tasks::Gis::LocalityHelper

  # @param [integer] distance (in meters)
  def collecting_events_nearby(distance)
    @collecting_events = @collecting_event.find_others_within_radius_of(distance)
  end

  def collecting_event_georeference_count(collecting_event)
    count = collecting_event.georeferences.count - 1
    if count > 0
      count.to_s
    else
      'none'
    end
  end

  def distance_between(collecting_event_1, collecting_event_2)
    distance = collecting_event_1.distance_to(collecting_event_2.geographic_items.first).round # to the nearest meter
    case
      when distance >= 1000.0
        metric = "%1.3fkm"
        distance /= 1000.0
      else
        metric = "%im"
    end
    metric % distance
  end

end
