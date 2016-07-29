FactoryGirl.define do
  factory :container_item, traits: [:housekeeping] do
    factory :valid_container_item do
      association :contained_object, factory: :valid_specimen
    end
  end
end
