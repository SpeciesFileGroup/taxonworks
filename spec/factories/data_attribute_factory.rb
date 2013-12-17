FactoryGirl.define do
  factory :data_attribute do
    factory :valid_attribute do
      type "DataAttribute::Import"
      association :attribute_subject, factory: :valid_specimen
      import_predicate "hair color"
      value "black"
    end
  end
end
