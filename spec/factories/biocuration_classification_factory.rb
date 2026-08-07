FactoryBot.define do
  factory :biocuration_classification, traits: [:housekeeping] do
    factory :valid_biocuration_classification do
      after(:build) do |biocuration_classification|
        FactoryProjectHelpers.assign_project_scoped(
          biocuration_classification,
          :biocuration_class,
          :valid_biocuration_class
        )
        FactoryProjectHelpers.assign_project_scoped(
          biocuration_classification,
          :biocuration_classification_object,
          :valid_specimen
        )
      end
    end
  end
end
