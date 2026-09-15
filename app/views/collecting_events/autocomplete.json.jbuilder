json.array! @collecting_events do |s|
  v = collecting_event_tag(s)
  json.id s.id
  json.label v

  # `collecting_event_autocomplete_tag` is empty for a collecting event described
  # only by a verbatim/print/document label, fall back to the label itself.
  # Note it can not fall back from within that method: `collecting_event_tag`
  # calls it.
  l = collecting_event_autocomplete_tag(s, term: params[:term]).presence || mark_tag(v, params[:term])

  # Only when the caller asked to restrict on georeferences.
  if params[:georeferences].present?
    l = [l, collecting_event_georeferences_tag(s)].compact.join('<br>')
  end

  json.label_html l

  json.response_values do 
    if params[:method]
      json.set! params[:method], s.id
    end
  end 
end
