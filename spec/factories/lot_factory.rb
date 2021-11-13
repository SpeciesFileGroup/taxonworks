FactoryBot.define do
  factory :lot, traits: [:housekeeping] do
    factory :valid_lot do
      total { 10 }
      no_dwc_occurrence { true }
    end
  end
end
