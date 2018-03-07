FactoryBot.define do
  factory :container_building, class: 'Container::Building', traits: [:housekeeping] do
    factory :valid_container_building
  end
end
