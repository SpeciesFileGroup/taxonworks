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

  def next_without_georeference_for_google_maps_link(collecting_event)
    if n = collecting_event.next_without_georeference
       link_to( 'Skip to next CE without georeference', new_georeferences_google_map_path(georeference: {collecting_event_id: n.to_param}), id: :next_without_georeference) 
    else
      nil
    end 
  end

end
