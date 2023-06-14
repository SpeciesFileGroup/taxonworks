FactoryBot.define do
  factory :cached_map_register do
    association :cached_map_object, factory: :valid_georeference
  end
end
