# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :geographic_area do
    name "MyString"
    country_id 1
    state_id 1
    county_id 1
    geographic_item nil
    parent_id 1
    geographic_area_type nil
  end
end
