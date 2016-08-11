FactoryGirl.define do
  factory :sequence, traits: [:housekeeping] do
    factory :valid_sequence do
      sequence "sequence"
      sequence_type "DNA"
    end
  end
end
