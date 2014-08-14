FactoryGirl.define do
  factory :topic, traits: [:housekeeping] do
    factory :valid_topic do
      name { Faker::Lorem.word }
      definition { Faker::Lorem.sentence }
    end
  end
end
