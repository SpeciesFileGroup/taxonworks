json.extract! image, :id, :height, :width, :image_file_fingerprint, :image_file_file_name, :image_file_file_size, :image_file_meta, :created_by_id, :updated_by_id, :pixels_to_centimeter

json.image do
  json.id image.id
  json.height image.height
  json.width image.width
  json.file_name image.image_file_file_name
 end
