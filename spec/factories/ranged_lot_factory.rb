FactoryGirl.define do
  factory :ranged_lot, traits: [:housekeeping] do
    factory :valid_ranged_lot do
      ranged_lot_category factory: :valid_ranged_lot_category
    end
  end
end
