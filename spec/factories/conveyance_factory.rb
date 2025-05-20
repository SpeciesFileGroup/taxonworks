FactoryBot.define do
  factory :conveyance, traits: [:housekeeping] do
    factory :valid_conveyance do
      association :conveyance_object, factory: :valid_specimen
      association :sound, factory: :valid_sound
    end
  end
end
