FactoryBot.define do
  factory :descriptor, traits: [:housekeeping] do
    factory :valid_descriptor do
      name { Faker::Lorem.unique.words(number: 5) }
      type { 'Descriptor::Working' }
    end
  end
end

