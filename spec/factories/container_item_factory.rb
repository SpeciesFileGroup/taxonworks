FactoryGirl.define do
  factory :container_item, traits: [:housekeeping] do
    factory :valid_container_item do
      association :container, factory: :valid_container
      association :contained_item, factory: :valid_specimen
    end
  end
end
