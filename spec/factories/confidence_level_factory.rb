FactoryBot.define do
  factory :confidence_level, traits: [:housekeeping] do
    factory :valid_confidence_level do
      name { Faker::Lorem.word + Faker::Number.number(5).to_s }
      definition { Faker::Lorem.sentence }
    end
  end
end
