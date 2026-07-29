json.array! @collecting_events do |s|
  v = collecting_event_tag(s)
  json.id s.id
  json.label v

  json.label_html collecting_event_autocomplete_tag(s, term: params[:term])

  json.response_values do 
    if params[:method]
      json.set! params[:method], s.id
    end
  end 
end
