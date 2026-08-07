FactoryBot.define do
  factory :preparation_type, traits: [:creator_and_updater] do
    name { Faker::Lorem.unique.characters(number: 12) }
    factory :valid_preparation_type  do
      definition { Faker::Lorem.unique.sentence(word_count: 6, supplemental: false, random_words_to_add: 3) }
    end
  end
end
