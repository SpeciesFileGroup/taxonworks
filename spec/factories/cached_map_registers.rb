FactoryBot.define do
  factory :cached_map_register, traits: [:projects] do
    factory :valid_cached_map_register do
      association :cached_map_register_object, factory: :valid_georeference
    end
  end
end
