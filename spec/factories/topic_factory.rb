FactoryGirl.define do
  factory :topic, traits: [:housekeeping] do
    factory :valid_topic do
      name 'Phenology' 
      definition 'Things about pheonology.'
    end
  end
end
