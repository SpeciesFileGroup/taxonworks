FactoryBot.define do
  factory :organization, traits: [:creator_and_updater] do
    factory :valid_organization do
      name { Faker::Lorem.word }
    end
  end
end
