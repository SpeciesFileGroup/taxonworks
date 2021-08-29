FactoryBot.define do
  factory :document, traits: [:creator_and_updater] do
    factory :valid_document do
      document_file { Rack::Test::UploadedFile.new( Spec::Support::Utilities::Files.generate_pdf(pages:1), 'application/pdf') }
    end
  end
end
