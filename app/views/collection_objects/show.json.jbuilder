#json.extract! @collection_object, :id, :total, :type, :preparation_type_id, :repository_id, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.success true
json.result do
	json.id @collection_object.id
	json.type @collection_object.type
	json.images do
		json.array! @collection_object.images do | image |
			json.id image.id
			json.url api_v1_image_url(image.to_param)
		end
	end
end