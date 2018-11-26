json.id image.id
json.width image.width
json.height image.height
json.content_type image.image_file_content_type
json.size image.image_file_file_size

# json.url root_url + image.image_file.url[1..-1]

json.partial! '/shared/data/all/metadata', object: image 

json.alternatives do
  json.medium do
    json.width image.image_file.width(:medium)
    json.height image.image_file.height(:medium)
    json.size image.image_file.size(:medium)
    json.url root_url + (image.image_file.url(:medium))[1..-1]
  end
  json.thumb do
    json.width image.image_file.width(:thumb)
    json.height image.image_file.height(:thumb)
    json.size image.image_file.size(:thumb)
    json.url root_url + (image.image_file.url(:thumb))[1..-1]
  end
end



