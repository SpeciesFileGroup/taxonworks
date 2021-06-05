json.array! @images do |i|
  v = image_autocomplete_tag(i)
  json.id i.id
  json.label i.cached
  json.label_html v
  json.image_object_global_id i.image_object.to_global_id.to_s

  json.image_object_id i.image_object_id
  json.image_object_type i.image_object_type

  json.response_values do
    if params[:method]
      json.set! params[:method], i.id
    end
  end
end
