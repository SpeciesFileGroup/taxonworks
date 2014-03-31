FactoryGirl.define do
  factory :biocuration_classification, traits: [:housekeeping] do
    factory :valid_biocuration_classification do
      association :biocuration_class, factory: :valid_biocuration_class
      association :biological_collection_object, factory: :valid_specimen
    end
  end
end
