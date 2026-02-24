FactoryBot.define do
  factory :person, traits: [:creator_and_updater] do
    factory :valid_person do
      last_name { Faker::Name.unique.last_name }
      type { 'Person::Unvetted' }
    end
  end
end
