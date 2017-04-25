json.array!(@images) do |image|
  json.partial! 'attributes', image: image
end
