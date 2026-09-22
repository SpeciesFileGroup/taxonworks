json.extract! image, :id, :height, :width, :image_file_fingerprint, :image_file_file_size, :pixels_to_centimeter
json.merge! image_api_attributes(image)

if extend_response_with('notes')
  json.notes image.notes.each do |n|
    json.text n.text
  end
end
