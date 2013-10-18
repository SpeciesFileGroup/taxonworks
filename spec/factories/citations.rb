# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :citation do
    citation_object_id "MyString"
    citation_object_type "MyString"
    references ""
  end
end
