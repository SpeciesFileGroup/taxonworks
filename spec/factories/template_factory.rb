FactoryBot.define do
  factory :template, traits: [:housekeeping] do
    factory :valid_template do
      name { Faker::Lorem.unique.word }
    end
  end
end
