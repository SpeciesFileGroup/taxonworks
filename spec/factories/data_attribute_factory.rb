FactoryGirl.define do
  factory :data_attribute do
    factory :valid_data_attribute do
      type 'ImportAttribute'
      association :attribute_subject, factory: :valid_otu
      import_predicate 'hair color'
      value 'black'
    end
  end
end
