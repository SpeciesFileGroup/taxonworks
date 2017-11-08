FactoryBot.define do
  factory :document, traits: [:creator_and_updater] do
    factory :valid_document do
      document_file { fixture_file_upload((Rails.root + 'spec/files/documents/tiny.pdf'), 'application/pdf') }
    end
  end

end
