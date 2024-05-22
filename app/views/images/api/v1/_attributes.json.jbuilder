json.extract! image, :id, :height, :width, :image_file_fingerprint, :image_file_file_name, :image_file_file_size, :created_by_id, :updated_by_id, :pixels_to_centimeter
json.original short_url(image.image_file)
json.thumb short_url(image.image_file.url(:thumb))
json.medium short_url(image.image_file.url(:medium))
json.content_type image.image_file_content_type
json.original_png original_as_png_via_api(image)

