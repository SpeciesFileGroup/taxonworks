FactoryBot.define do
  factory :cached_map_item, traits: [:projects] do
    factory :valid_cached_map_item do
      association :otu, factory: :valid_otu 
      association :geographic_item, factory: :valid_geographic_item
      type { 'CachedMap::WebLevel1' } 
      reference_count { 1 }
    end
  end
end
