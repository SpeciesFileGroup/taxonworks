class Tasks::Gis::LocalityController < ApplicationController
  include TaskControllerConfiguration

  def nearby
    @related_routes = UserTasks.related_routes('nearby_locality_task')
    @collecting_event = CollectingEvent.find(params[:id])
    # @nearby_distance = 5000
    @nearby_distance  = params['nearby_distance'].to_i
    if @nearby_distance == 0
      @nearby_distance = CollectingEvent::NEARBY_DISTANCE
    end

    case @nearby_distance.to_s.length
      when 1..2
        decade = 10
      when 3
        decade = 100
      when 4
        decade = 1000
      when 5
        decade = 10000
      when 6
        decade = 100000
      when 7
        decade = 1000000
      when 8
        decade = 10000000
      else
        decade = 10
    end
    digit = (@nearby_distance.to_f / decade.to_f).round

    case digit
      when 0..1
        digit = 1
      when 2
        digit = 2
      when 3..5
        digit = 5
      when 6..10
        digit = 1
        decade *= 10
    end

    # radio_button('post', 'digit2', '10000')
    params['digit1'] = digit.to_s
    params['digit2'] = decade.to_s
    @nearby_distance = digit * decade
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
