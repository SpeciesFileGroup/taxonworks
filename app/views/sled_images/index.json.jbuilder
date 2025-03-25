json.array!(@sled_images) do |sled_image|
  json.partial! '/sled_images/attributes', sled_image: sled_image
end
