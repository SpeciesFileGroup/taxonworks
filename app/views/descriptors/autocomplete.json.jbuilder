json.array! @descriptors do |d|
  json.id d.id
  json.label d.name
  json.gid d.to_global_id.to_s 
  json.label_html descriptors_autocomplete_tag(d, @term) 

  json.response_values do 
    if params[:method]
      json.set! params[:method], d.id
    end
  end 
end
