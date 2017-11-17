FactoryBot.define do
  factory :container_vial, class: 'Container::Vial', traits: [:housekeeping] do
    factory :valid_container_vial
  end
end
