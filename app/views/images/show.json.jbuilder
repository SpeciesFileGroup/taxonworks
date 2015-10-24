# json.extract! @image, :id, :user_file_name, :height, :width, :image_file_fingerprint, :created_by_id, :project_id, :image_file_file_name, :image_file_content_type, :image_file_file_size, :image_file_updated_at, :updated_by_id, :created_at, :updated_at

json.success true
json.result do
	json.id @image.id
	json.width @image.width
	json.height @image.height
	json.content_type @image.image_file_content_type
	json.size @image.image_file_file_size
	json.url root_url + @image.image_file.url[1..-1]
	json.alternatives do
		json.medium do
			json.width @image.image_file.width(:medium)
			json.height @image.image_file.height(:medium)
			json.size @image.image_file.size(:medium)
			json.url root_url + (@image.image_file.url(:medium))[1..-1]
		end
		json.thumb do
			json.width @image.image_file.width(:thumb)
			json.height @image.image_file.height(:thumb)
			json.size @image.image_file.size(:thumb)
			json.url root_url + (@image.image_file.url(:thumb))[1..-1]
		end
	end
end