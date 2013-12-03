# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :alternate_value do
    value "MyText"
    type ""
    language nil
    alternate_type "MyString"
    alternate_id 1
    alternate_attribute "MyString"
  end
end
