FactoryBot.define do
  factory :import_dataset, class: ImportDataset::DarwinCore::Occurrences, traits: [:creator_and_updater] do

    factory :valid_import_dataset do
      source { fixture_file_upload((Rails.root + 'spec/files/import_datasets/dwca_occurrences.txt'), 'text/plain') }
      description { 'Testing' }
    end
  end
end
