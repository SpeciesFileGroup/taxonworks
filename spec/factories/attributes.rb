# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :attribute do
    type ""
    attribute_subject_id 1
    attribute_subject_type "MyString"
    controlled_vocabularly_term_id 1
    import_predicate "MyString"
    value "MyString"
  end
end
