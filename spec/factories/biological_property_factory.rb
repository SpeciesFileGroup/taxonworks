FactoryGirl.define do
  factory :biological_property, class: BiologicalProperty, traits: [:housekeeping] do
    factory :valid_biological_property do
      name {Faker::Lorem.word}
      definition {Faker::Lorem.sentence}
    end
  end
end
