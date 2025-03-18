FactoryBot.define do
  factory :protocol, traits: [:housekeeping] do
    factory :valid_protocol do
      name { Faker::Name.unique.name }
      short_name {  Faker::Name.unique.name }
      description { "The #{Faker::Name.unique.name} that #{Faker::Name.unique.name}." }
    end
  end
end
