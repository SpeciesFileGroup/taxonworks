FactoryGirl.define do
  factory :topic, traits: [:housekeeping] do
    factory :valid_topic do
      name { Faker::Lorem.word + Faker::Number.number(5).to_s }
      definition { Faker::Lorem.sentence }
    end
  end
end
