FactoryGirl.define do
  factory :character_state, traits: [:housekeeping] do
    factory :valid_character_state do
      association :descriptor, factory: :valid_descriptor_qualitative
      name { Faker::Lorem.word }
      label '0'
    end
  end
end


