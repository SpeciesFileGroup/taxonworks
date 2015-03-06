FactoryGirl.define do
  factory :biological_property, class: BiologicalProperty, traits: [:housekeeping] do
    factory :valid_biological_property do
      name { Faker::Lorem.characters(12) }
      definition { Faker::Lorem.sentence(6, false, 3) }
    end
  end
end
