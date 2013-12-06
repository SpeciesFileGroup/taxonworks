# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :repository do
    name "MyString"
    url "MyString"
    acronym "MyString"
    status "MyString"
    institutional_LSID "MyString"
    is_index_herbarioum_record false
  end
end
