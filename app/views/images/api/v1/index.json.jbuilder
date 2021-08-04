json.array!(@images) do |image|
  json.partial! '/images/api/v1/attributes', image: image
end
