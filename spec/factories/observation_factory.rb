FactoryGirl.define do
  factory :observation, traits: [:housekeeping] do
    factory :valid_observation do
      association :descriptor, factory :valid_descriptor
      association :otu, factory :valid_otu
      type 'Observation::Continuous' 
      continuous_value: 42
    end
  end
end
