FactoryGirl.define do
  factory :derived_collection_object, traits: [:housekeeping] do
    factory :valid_derived_collection_object do
      association :collection_object, factory: :valid_specimen
      association :collection_object_observation, factory: :valid_collection_object_observation
    end
  end
end
