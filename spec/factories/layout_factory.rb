FactoryBot.define do
  factory :layout, traits: [:housekeeping] do
    factory :valid_layout do
      name { Faker::Lorem.unique.word }
    end
  end
end
