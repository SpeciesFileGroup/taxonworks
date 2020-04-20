FactoryBot.define do
  factory :namespace, traits: [:creator_and_updater] do
    factory :valid_namespace do
      # name 'All my things'
      # short_name 'AMT'
      name { Faker::Lorem.unique.sentence }
      short_name { Faker::Lorem.unique.word + Faker::Number.number(digits: 5).to_s }
    end
  end
end
