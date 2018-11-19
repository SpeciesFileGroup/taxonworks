# TODO: Deprecate for json-api and/or internal
json.success true
json.request do
  json.params do
    json.project_id @request_project_id
    json.identifier @identifier
  end
  json.url request.url
end
json.result do
  json.collection_objects do
    json.array! @collection_objects do |item|
      json.id item.id
      json.url collection_object_url(item) # api_v1_collection_object_url(item.to_param)
    end
  end
end
