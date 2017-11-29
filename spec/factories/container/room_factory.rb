FactoryBot.define do
  factory :container_room, class: 'Container::Room', traits: [:housekeeping] do
    factory :valid_container_room
  end
end
