FactoryGirl.define do
  factory :confidence, traits: [:housekeeping] do
    factory :valid_confidence do
      confidence_object ""
    end
  end
end
