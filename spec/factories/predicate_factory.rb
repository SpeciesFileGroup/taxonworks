FactoryGirl.define do
  factory :controlled_vocabulary_term_predicate, class: Predicate, traits: [:housekeeping] do
    factory :valid_controlled_vocabulary_term_predicate do
      # name 'Color'
      # definition 'A food group, like "purple".'
      name { Faker::Lorem.word }
      definition { Faker::Lorem.sentence }
    end
  end
end
