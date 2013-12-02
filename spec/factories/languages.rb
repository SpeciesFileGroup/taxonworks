# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :language do
    alpha_3_bibliographic "MyString"
    alpha_3_terminologic "MyString"
    alpha_2 "MyString"
    english_name "MyString"
    french_name "MyString"
  end
end
