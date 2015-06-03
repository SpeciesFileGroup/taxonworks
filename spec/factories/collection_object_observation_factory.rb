FactoryGirl.define do
  factory :collection_object_observation, traits: [:housekeeping] do
    factory :valid_collection_object_observation do
      data "long string\nof metadata|about some specimen\nidentifer 123\n\rweird line endings"
    end
  end

end
