json.array! @serials do |s|
  json.id s.id
  json.label serial_tag(s) 
  json.label_html serial_autocomplete_tag(s, params[:term]) 

  json.response_values do 
    if params[:method]
      json.set! params[:method], s.id
    end
  end
end
