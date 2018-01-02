json.result do
  json.id collection_object.id
  json.type collection_object.type
  json.object_tag collection_object_tag(collection_object)
  json.images do
    json.array! collection_object.images do |image|
      json.id image.id
      json.url api_v1_image_url(image.to_param)
    end
  end if collection_object.images
end
