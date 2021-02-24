FactoryBot.define do
  factory :sled_image, traits: [:creator_and_updater] do
    factory :valid_sled_image do
      association :image, factory: :valid_image
      metadata { [ { "index": 0,
                     "upperCorner": {"x":0, "y":0},
                     "lowerCorner": {"x":4, "y":4},
                     "row": 0,
                     "column": 0 }] } 
    end
  end
end
