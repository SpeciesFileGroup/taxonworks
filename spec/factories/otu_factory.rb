FactoryBot.define do
  factory :otu, traits: [:housekeeping] do
    factory :valid_otu do
      sequence(:name) { |n| "#{Faker::Lorem.word}#{n}" }
    end
  end
end
