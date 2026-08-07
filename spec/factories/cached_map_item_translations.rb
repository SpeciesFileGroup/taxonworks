FactoryBot.define do
  factory :cached_map_item_translation do
    factory :valid_cached_map_item_translation do
      association :geographic_item, factory: :valid_geographic_item
      association :translated_geographic_item, factory: :valid_geographic_item
    end
  end
end
