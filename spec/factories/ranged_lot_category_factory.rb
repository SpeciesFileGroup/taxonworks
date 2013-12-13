# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ranged_lot_category, traits: [:housekeeping] do
    name "MyString"
    minimum_value 1
    maximum_value 1
  end
end
