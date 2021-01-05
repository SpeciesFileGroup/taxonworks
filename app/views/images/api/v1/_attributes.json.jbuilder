json.extract! image, :id, :height, :width, :image_file_fingerprint, :image_file_file_name, :image_file_file_size, :image_file_meta, :created_by_id, :updated_by_id, :pixels_to_centimeter

json.image_object do
  json.id image.image_object_id
  json.type image.image_object_type
  json.type image.image_object.to_global_id.to_s
end
