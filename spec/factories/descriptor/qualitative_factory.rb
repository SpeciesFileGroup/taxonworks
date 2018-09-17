FactoryBot.define do
  factory :descriptor_qualitative, class: 'Descriptor::Qualitative', traits: [:housekeeping] do
    factory :valid_descriptor_qualitative do
      name { Faker::Lorem.word }
      type { 'Descriptor::Qualitative' }
    end
  end
end

