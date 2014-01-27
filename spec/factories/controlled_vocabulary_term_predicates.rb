FactoryGirl.define do
  factory :controlled_vocabulary_term_predicate, class: ControlledVocabularyTerm::Predicate, traits: [:housekeeping] do
    factory :valid_controlled_vocabulary_term_predicate do
      name 'Color'
      definition 'A food group, like "purple".'
    end
  end
end
