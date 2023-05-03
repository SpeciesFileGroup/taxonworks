json.array! @collection_objects do |s|
  v = collection_object_autocomplete_tag(s)
  json.id s.id
  json.label label_for_collection_object(s)
  json.gid s.to_global_id.to_s
  json.label_html v

  json.response_values do 
    if params[:method]
      json.set! params[:method], s.id
    end
  end 
end
