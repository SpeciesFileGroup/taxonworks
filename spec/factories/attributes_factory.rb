
FactoryGirl.define do
  factory :attribute do
    type nil 
    attribute_subject_id nil
    attribute_subject_type nil
    controlled_vocabularly_term_id nil
    import_predicate nil
    value "some_value"
  end

  factory :valid_attribute, class: Attribute::Import do
    type "Attribute::Import"
    association :attribute_subject, factory: :valid_specimen
    import_predicate "hair color"
    value "black"
  end

end
