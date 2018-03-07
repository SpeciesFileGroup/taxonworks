FactoryBot.define do
  factory :controlled_vocabulary_term_predicate, class: Predicate, traits: [:housekeeping] do
    factory :valid_controlled_vocabulary_term_predicate, traits: [:random_name, :random_definition] 
  end
end
