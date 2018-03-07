FactoryBot.define do
  factory :confidence, traits: [:housekeeping] do
    factory :valid_confidence do
      association :confidence_object, factory: :valid_specimen
      association :confidence_level, factory: :valid_confidence_level  
    end
  end
end
