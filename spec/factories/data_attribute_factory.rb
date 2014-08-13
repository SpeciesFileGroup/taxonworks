FactoryGirl.define do
  factory :data_attribute, traits: [:creator_and_updater] do
    factory :valid_data_attribute do
      type 'ImportAttribute'
      association :attribute_subject, factory: :valid_otu
      import_predicate {Faker::Lorem.words(2).join(" ")}
      value {Faker::Number.number(5)}
    end
  end
end
