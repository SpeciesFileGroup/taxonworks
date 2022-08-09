FactoryBot.define do
  factory :dataset_record, class: DatasetRecord::DarwinCore::Occurrence, traits: [:creator_and_updater] do

    # TODO: Just providing it for models/project_spec.rb to pass. Not usable. Perhaps project_id should be dropped and have it in ImportDataset only.
    factory :valid_dataset_record do
    end
  end
end
