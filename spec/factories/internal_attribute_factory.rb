FactoryGirl.define do
  factory :data_attribute_internal_attribute, class: InternalAttribute, traits: [:housekeeping] do
    factory :valid_data_attribute_internal_attribute do
      value {Faker::Lorem.word}
      association :predicate, factory: :valid_controlled_vocabulary_term_predicate
      association :attribute_subject, factory: :valid_otu
    end
  end
end
