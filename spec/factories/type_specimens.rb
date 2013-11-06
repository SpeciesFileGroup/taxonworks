# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :type_specimen do
    biological_object nil
    taxon_name nil
    type_type "MyString"
  end
end
