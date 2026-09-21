json.extract! image, :id, :height, :width, :image_file_fingerprint, :image_file_file_size, :pixels_to_centimeter
json.content_type image.image_file_content_type
json.attributed image.attributed?

if image.attributed?
  json.image_file_file_name image.image_file_file_name
  json.original short_url(image.image_file)
  json.thumb short_url(image.image_file.url(:thumb))
  json.medium short_url(image.image_file.url(:medium))
  json.original_png original_as_scaled_png_via_api(image)
  json.as_png original_as_png_via_api(image)
else
  json.message 'Image is not accessible via the API because it lacks attribution. See https://api.taxonworks.org/ for more.'
end

if extend_response_with('notes')
  json.notes image.notes.each do |n|
    json.text n.text
  end
end
