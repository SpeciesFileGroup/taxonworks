json.otu_id @otu.id

json.cached_map do
  json.id @quicker_cached_map.id
  json.geo_json @quicker_cached_map.geo_json_to_s
end
