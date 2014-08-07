module CollectingEventsHelper

  def self.collecting_event_tag(collecting_event)
    # collecting_event.cached.blank? ? 'CACHED VALUE NOT BUILT - CONTACT ADMIN' : collecting_event.cached
    return nil if collecting_event.nil?
    collecting_event.verbatim_locality
  end

  def collecting_event_tag(collecting_event)
    CollectingEventsHelper.collecting_event_tag(collecting_event)
  end

  def collecting_event_link(collecting_event)
    return nil if collecting_event.nil?
    link_to(collecting_event_tag(collecting_event).html_safe, collecting_event)
  end

  def collecting_event_search_form
    render('/collecting_events/quick_search_form')
  end

  def collecting_event_geographic_area_select_tag(geographic_area_id)
    # TODO: What goes here?
    # if geographic_area_id.nil?
    #   return nil # jdt?
    # end
    # GeographicArea.all.limit(5).to_a
  end

end
