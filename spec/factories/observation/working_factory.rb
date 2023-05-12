FactoryBot.define do
  factory :observation_working, class: Observation::Working, traits: [:housekeeping] do
    factory :valid_observation_working do
      association :descriptor, factory: :valid_descriptor, type: 'Descriptor::Working'
      association :observation_object, factory: :valid_otu
      type { 'Observation::Working' } 
      description { 'With stubbed toe' }
    end
  end
end
