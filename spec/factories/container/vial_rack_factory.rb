FactoryBot.define do
  factory :container_vial_rack, class: 'Container::VialRack', traits: [:housekeeping] do
    factory :valid_container_vial_rack
  end
end
