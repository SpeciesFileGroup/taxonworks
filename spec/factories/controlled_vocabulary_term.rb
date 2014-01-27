FactoryGirl.define do
  factory :controlled_vocabulary_term, traits: [:housekeeping] do
    factory :valid_controlled_vocabulary_term do
      name 'Color'
      definition 'A food group, like "purple".'
    end
  end
end
