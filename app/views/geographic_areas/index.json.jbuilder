json.array!(@geographic_areas) do |geographic_area|
  json.partial! '/geographic_areas/attributes', geographic_area:
end
