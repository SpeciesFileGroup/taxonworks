FactoryBot.define do
  factory :observation_presence_absence, class: Observation::PresenceAbsence, traits: [:housekeeping] do
    factory :valid_observation_presence_absence do
      association :descriptor, factory: :valid_descriptor, type: 'Descriptor::PresenceAbsence'
      association :observation_object, factory: :valid_otu
      type { 'Observation::PresenceAbsence' } 
      presence { true } 
    end
  end
end
