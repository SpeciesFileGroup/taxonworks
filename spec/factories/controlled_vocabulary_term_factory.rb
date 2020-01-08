FactoryBot.define do

  trait :random_name do
    # Could be Faker.characters(number: 10)
    name { Utilities::Strings.random_string(10) }
  end

  trait :random_definition do
    definition { "The #{Utilities::Strings.random_string(8)} that #{Utilities::Strings.random_string(8)}." }
  end

  factory :controlled_vocabulary_term, traits: [:housekeeping] do
    factory :valid_controlled_vocabulary_term, traits: [:random_name, :random_definition] do
      type { 'Keyword' }
      uri { '' }
      uri_relation { '' }
    end

    factory :random_controlled_vocabulary_term, traits: [:random_name, :random_definition]
  end

end
