#json.extract! @collection_object, :id, :total, :type, :preparation_type_id, :repository_id, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.success true
json.result do
  json.id @collection_object.id
  json.type @collection_object.type
  json.geo_json @collection_object.try(:collecting_event).to_geo_json_feature if @geo_json
  json.images do
    json.array! @images do |image|
      json.id image.id
      json.url api_v1_image_url(image.to_param)
    end
  end if @images
end

# curl 'http://localhost:3000/api/v1/collection_objects/3?token=FindYourOwnToken&project_id=1&include=geo_json'
# wget "http://localhost:3000/api/v1/collection_objects/3?token=FindYourOwnToken&project_id=1&include=geo_json" -O tmp/test.json

