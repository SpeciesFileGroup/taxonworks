FactoryGirl.define do
  factory :ranged_lot_category, traits: [:housekeeping] do
    factory :valid_ranged_lot_category do
      name "one or two"
      minimum_value 1
      maximum_value 2
    end
  end
end
