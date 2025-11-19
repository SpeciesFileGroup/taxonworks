FactoryBot.define do

  factory :news, traits: [:housekeeping] do
    factory :valid_news do
      title { Faker::Lorem.unique.word }
      title { Faker::Lorem.unique.text }
    end
  end

end
