FactoryBot.define do
  factory :valid_cached_map_geographic_item_translation do
    association :geographic_item, factory: :valid_geographic_item
    association :translated_geographic_item, factory: :valid_geographic_item
  end
end
