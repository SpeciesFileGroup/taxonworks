FactoryBot.define do
  factory :cached_map, traits: [:projects] do
    factory :valid_cached_map do
      association :otu, factory: :valid_otu 
      geometry { RGeo::GeoJSON.decode('{"type": "Polygon", "coordinates": [[[14.67292, 13.034527, 0], [14.67292, 18.27943, 0], [21.70636, 18.27943, 0], [21.70636, 13.034527, 0], [14.67292, 13.034527, 0]]]}', json_parser: :json) }
      reference_count { 1 }
      cached_map_type { 'CachedMap::WebLevel1' } 
    end
  end
end
