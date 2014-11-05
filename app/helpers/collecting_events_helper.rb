module CollectingEventsHelper

  def collecting_event_tag(collecting_event)
    return nil if collecting_event.nil?
    string = [ collecting_event.cached,  collecting_event.verbatim_label, collecting_event.print_label, collecting_event.document_label, collecting_event.field_notes, collecting_event.to_param].compact.first 
    string
  end

  def collecting_event_link(collecting_event)
    return nil if collecting_event.nil?
    link_to(collecting_event_tag(collecting_event).html_safe, collecting_event)
  end

  def collecting_events_search_form
    render('/collecting_events/quick_search_form')
  end

end
