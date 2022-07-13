FactoryBot.define do
  factory :specimen, traits: [:housekeeping] do
    factory :valid_specimen do
      total { 1 }
      no_dwc_occurrence { true }
    end
  end
end
