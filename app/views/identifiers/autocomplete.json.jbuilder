json.array! @identifiers do |i|
  v = identifier_autocomplete_tag(i)
  json.id i.id
  json.label i.cached
  json.short_name i.short_name
  json.label_html v 

  json.response_values do 
    if params[:method]
      json.set! params[:method], i.id
    end
  end 
end
