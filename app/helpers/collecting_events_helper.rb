module CollectingEventsHelper

  def collecting_event_tag(collecting_event)
    return nil if collecting_event.nil?
    string = [collecting_event.cached, collecting_event.verbatim_label, collecting_event.print_label, collecting_event.document_label, collecting_event.field_notes, collecting_event.to_param].compact.first
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
      link_to('Skip to next CE without georeference', new_georeferences_google_map_path(georeference: {collecting_event_id: n.to_param}), id: :next_without_georeference)
    else
      nil
    end
  end

  # @return [String]
  #   short string of use in autocomplete selects
  def collecting_event_namespace_select_tag
    select_tag(:ce_namespace, options_for_select(Namespace.pluck(:short_name).uniq), prompt: 'Select a namespace')
  end

  # @return [String, nil]
  #   summary of elevation data
  def elevation_tag(collecting_event)
    return nil if collecting_event.nil?
    [
      Utilities::Strings.nil_wrap(nil, [collecting_event.minimum_elevation, collecting_event.maximum_elevation].compact.join('-'), 'm'), 
      Utilities::Strings.nil_wrap(' +/-', collecting_event.elevation_precision, nil)
    ].compact.join.html_safe
  end

  # @return [String, nil]
  #   summary of date data
  def date_range_tag(collecting_event)
    return if collecting_event.nil?
    [collecting_event.start_date_string, collecting_event.end_date_string].compact.join(' - ')
  end

  # @return [String, nil]
  #   summary of verbatim gis related data
  def verbatim_gis_tag(collecting_event)
    return if collecting_event.nil?
    [collecting_event.verbatim_latitude, 
     collecting_event.verbatim_longitude,
     Utilities::Strings.nil_wrap(' (+/-', collecting_event.verbatim_geolocation_uncertainty, ')'),
     Utilities::Strings.nil_wrap(' [via ', collecting_event.verbatim_datum, ']'),
    ].compact.join(', ')
  end

  # @return [HTML] a pre tag formatting a label
  def collecting_event_label_tag(label_text)
    content_tag(:pre, label_text, class: [:large_type, :word_break] ) # large_type needs to be larger
  end

end
