FactoryBot.define do
  factory :composition, traits: [:housekeeping] do
    factory :valid_composition do
      type { 'Layout' }
      name { Faker::Lorem.unique.word }
    end

    initialize_with { new(type: type) }
  end
end
