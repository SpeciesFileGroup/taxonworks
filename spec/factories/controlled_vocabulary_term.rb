FactoryGirl.define do
  factory :controlled_vocabulary_term, class: ControlledVocabularyTerm, traits: [:housekeeping] do
    factory :valid_controlled_vocabulary_term do
      name 'Color'
      definition 'A food group, like "purple".'
      type 'Keyword' 
    end
  end
end
