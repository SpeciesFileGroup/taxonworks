module CollectingEventsHelper

  # self. pattern is going away, it can't include instance methods, i.e. other helpers
  def self.collecting_event_tag(collecting_event)
    return nil if collecting_event.nil?
    content_tag(:pre, collecting_event.verbatim_label)
  end

  def collecting_event_tag(collecting_event)
    CollectingEventsHelper.collecting_event_tag(collecting_event)
  end

  def collecting_event_link(collecting_event)
    return nil if collecting_event.nil?
    link_to(collecting_event_tag(collecting_event).html_safe, collecting_event)
  end

  def collecting_events_search_form
    render('/collecting_events/quick_search_form')
  end

end
