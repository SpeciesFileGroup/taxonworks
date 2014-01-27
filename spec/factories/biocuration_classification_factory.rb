FactoryGirl.define do
  factory :biocuration_classification, traits: [:housekeeping] do
    biocuration_class nil
    biological_collection_object nil
    position 1
  end
end
