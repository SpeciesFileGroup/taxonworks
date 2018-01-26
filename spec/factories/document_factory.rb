FactoryBot.define do
  factory :document, traits: [:creator_and_updater] do
    factory :valid_document do
      document_file { fixture_file_upload( Spec::Support::Utilities::Files.generate_pdf(pages:1), 'application/pdf') }
    end
  end
end
