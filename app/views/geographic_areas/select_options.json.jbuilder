@geographic_areas.each_key do |group|
  json.set!(group) do
    json.array! @geographic_areas[group] do |k|
      json.partial! '/geographic_areas/attributes', geographic_area: k
    end
  end
end
