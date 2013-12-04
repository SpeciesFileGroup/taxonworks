FactoryGirl.define do
  factory :specimen, class: Specimen do
  end

  factory :valid_specimen, class: Specimen do
    total 1
  end
end
