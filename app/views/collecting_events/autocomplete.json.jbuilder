json.array! @collecting_events do |s|
  v =  collecting_event_tag(s)
  json.id s.id
  json.label v
  json.label_html v 

  json.response_values do 
    if params[:method]
      json.set! params[:method], s.id
    end
  end 
end
