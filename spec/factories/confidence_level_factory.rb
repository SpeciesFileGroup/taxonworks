FactoryGirl.define do
  factory :confidence_level, traits: [:housekeeping] do
    factory :valid_confidence_level, traits: [:random_name, :random_definition]
  end
end
