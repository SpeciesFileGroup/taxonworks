FactoryBot.define do
  factory :sled_image, traits: [:creator_and_updater] do
    factory :valid_sled_image do
      association :image, factory: :valid_image
    end
  end
end
