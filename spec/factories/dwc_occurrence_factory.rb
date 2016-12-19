FactoryGirl.define do
  factory :dwc_occurrence, traits: [:housekeeping] do
    factory :valid_dwc_occurrence do
      association :dwc_occurrence_object, factory: :valid_specimen
    end
  end
end
