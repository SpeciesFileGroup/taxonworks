FactoryBot.define do
  factory :descriptor_working, class: 'Descriptor::Working', traits: [:housekeeping] do
    factory :valid_descriptor_working do
      name { Faker::Lorem.word }
      type { 'Descriptor::Working' }
    end
  end
end

