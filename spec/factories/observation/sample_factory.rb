FactoryBot.define do
  factory :observation_sample, class: Observation::Sample, traits: [:housekeeping] do
    factory :valid_observation_sample do
      association :descriptor, factory: :valid_descriptor, type: 'Descriptor::Sample'
      association :observation_object, factory: :valid_otu
      type { 'Observation::Sample' } 
      sample_min { 10 }
    end
  end
end
