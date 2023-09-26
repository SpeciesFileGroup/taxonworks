json.array!(@depictions) do |depiction|
  json.partial! '/depictions/api/v1/gallery_item', depiction: 
end
