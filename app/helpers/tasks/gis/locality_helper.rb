module Tasks::Gis::LocalityHelper

  def ay_range
    ('A'..'Y')
  end

  def az_range
    ay_range.to_a.push('Z')
  end

  def anchor_shade(letter)
    style = 'display:inline;'
    if select_locality_count(letter) == 0
      style += 'color:lightgrey;'
    end

    #"<p>
    #  <h3 style=\>#{letter}</h3>
    #  <a href=\"#top\">top</a>
    #</p>"

    "<p><h3 style=\"#{style}\">#{letter}</h3> <a href=\"#top\">top</a></p>"

    # TODO: change to class
    # content_tag(:p) do
    #   content_tag(:h3, letter, style: style ) do
    #     link_to('top', '#top')
    #   end
    # end
  end

  def select_locality_count(letter)
    select_locality(letter).count
  end

  # localities within @geographic_item which have a verbatim_locality starting with letter
  def select_locality(letter)
    s = CollectingEvent.where(id: @collecting_events.ids)
          .where('verbatim_locality like ?', letter.to_s + '%')
          .order(:verbatim_locality)
    s
  end

  def locality_georeferences(collecting_events, geographic_area)
    retval = []
    unless collecting_events.nil?
      retval = collecting_events.map(&:georeferences).flatten
    end
    if retval.empty?
      retval.push(geographic_area)
    end
    retval
  end

  def missing_verbatim_locality_count(collecting_events)
    collecting_events.where(verbatim_locality: nil).count
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
    distance = collecting_event_1.distance_to(collecting_event_2.preferred_georeference.geographic_item_id).round
    # to the nearest meter
    case
      when distance >= 1000.0
        metric = '%1.3fkm'
        distance /= 1000.0
      else
        metric = '%im'
    end
    metric % distance
  end

  def nearby_link(collecting_event)
    return nil if collecting_event.nil?
    link_to('nearby', collecting_event)
  end

  def distance_select_tag(digit, tag_string)
    tag = tag_string.gsub(',', '')

    label_tag(digit, tag_string)
    radio_button_tag(digit, tag.to_s)
  end

  def is_checked(digit, value)
    (params[digit] == value) ? true : false
  end

  def within_count
    @collecting_events_count = CollectingEvent.contained_within(@geographic_item).count
  end

end
