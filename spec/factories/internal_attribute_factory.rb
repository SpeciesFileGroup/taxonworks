FactoryGirl.define do
  factory :data_attribute_internal_attribute, class: InternalAttribute, traits: [:housekeeping] do
    factory :valid_data_attribute_internal_attribute do
      value 'purple'
      association :predicate, factory: :valid_controlled_vocabulary_term_predicate
    end
  end
end
