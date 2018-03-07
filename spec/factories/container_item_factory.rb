FactoryBot.define do
  factory :container_item, traits: [:housekeeping] do
    factory :valid_container_item do
      association :contained_object, factory: :valid_specimen
      association :parent, factory: :parent_container_item
    end

    factory :parent_container_item do
      association :contained_object, factory: :valid_container
    end

  end
end
