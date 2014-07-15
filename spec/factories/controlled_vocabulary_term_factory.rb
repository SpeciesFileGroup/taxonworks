FactoryGirl.define do

  trait :random_name do 
     name { Utilities::Strings.random_string(10) }
  end

  trait :random_definition do
    definition { "The #{Utilities::Strings.random_string(8)} that #{Utilities::Strings.random_string(8)}." }
  end

  factory :controlled_vocabulary_term, class: ControlledVocabularyTerm, traits: [:housekeeping] do
    factory :valid_controlled_vocabulary_term do
      name 'Color'
      definition 'A food group, like "purple".'
      type 'Keyword' 
    end

    factory :random_controlled_vocabulary_term, traits: [:random_name, :random_definition] 

  end

end
