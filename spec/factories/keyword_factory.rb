FactoryBot.define do
  
  factory :keyword, traits: [:housekeeping] do
    factory :valid_keyword do
      name { Faker::Lorem.word + Faker::Number.number(digits: 5).to_s }
      definition { Faker::Lorem.sentence(word_count: 10) }

      factory :valid_predicate, class: 'Predicate'

    end
  end

end
