FactoryBot.define do
  factory :descriptor_continuous, class: 'Descriptor::Continuous', traits: [:housekeeping] do
    factory :valid_descriptor_continuous do
      name { Faker::Lorem.word }
      type 'Descriptor::Continuous'
    end
  end
end

