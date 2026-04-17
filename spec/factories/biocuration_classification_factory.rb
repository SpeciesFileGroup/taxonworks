FactoryBot.define do
  factory :biocuration_classification, traits: [:housekeeping] do
    factory :valid_biocuration_classification do
      association :biocuration_class, factory: :valid_biocuration_class
      after(:build) do |bc|
        bc.biocuration_classification_object ||= FactoryBot.create(:valid_specimen, project_id: bc.project_id)
      end
    end
  end
end
