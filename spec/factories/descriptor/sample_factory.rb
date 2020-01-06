FactoryBot.define do
  factory :descriptor_sample, class: 'Descriptor::Sample', traits: [:housekeeping] do
    factory :valid_descriptor_sample do
      name { Faker::Lorem.unique.word }
      type { 'Descriptor::Sample' }
    end
  end
end

