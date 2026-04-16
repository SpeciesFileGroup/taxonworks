FactoryBot.define do
  factory :biocuration_classification, traits: [:housekeeping] do
    factory :valid_biocuration_classification do
      association :biocuration_class, factory: :valid_biocuration_class
      association :biocuration_classification_object, factory: :valid_specimen
    end
  end
end
