FactoryBot.define do
  factory :origin_relationship, traits: [:housekeeping] do
    factory :valid_origin_relationship do
      association :old_object, factory: :valid_collection_object
      association :new_object, factory: :valid_collection_object
    end
  end
end
