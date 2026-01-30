FactoryBot.define do

  factory :source_bibtex, class: Source::Bibtex, traits: [:creator_and_updater] do
    factory :valid_source_bibtex do
      bibtex_type { 'article' }
      title { 'article 1 just title' }
    end

    factory :source_bibtex_with_document, parent: :valid_source_bibtex do
      transient do
        size_bytes { 1.megabyte }
        filename { nil }
        pages { nil }
      end

      after(:create) do |source, evaluator|
        filename = evaluator.filename || "doc-#{SecureRandom.hex(4)}.pdf"
        pages = evaluator.pages || rand(1..3)

        ProjectSource.create!(source_id: source.id)

        document = FactoryBot.create(
          :document,
          document_file: Rack::Test::UploadedFile.new(
            Spec::Support::Utilities::Files.generate_pdf(
              pages: pages,
              file_name: filename
            ),
            'application/pdf'
          )
        )
        document.update_column(:document_file_file_size, evaluator.size_bytes)

        Documentation.create!(
          documentation_object: source,
          document: document
        )
      end
    end

    factory :soft_valid_bibtex_source_article do
      bibtex_type { 'article' }
      title { 'I am a soft valid article' }
      author { 'Person, Test' }
      journal { 'Journal of Test Articles' }
      year { 1700 }
    end

    factory :valid_bibtex_source_book_title_only do
      bibtex_type { 'book' }
      title { 'valid book with just a title' }
    end

    factory :valid_thesis do
      bibtex_type { 'phdthesis' }
      title { 'Bugs by Beth' }
      author { 'Jones, Beth' }
      year { 1982 }
      month { 'jun' }
    end

    factory :valid_misc do
      bibtex_type { 'misc' }
      title { 'misc source' }
      year { 2010 }
      month { 'jul' }
      day { 4 }
    end

    factory :src_mult_authors do
      bibtex_type { 'article' }
      title { 'Article with multiple authors' }
      author { 'Thomas, Dave and Fowler, Chad and Hunt, Andy' }
      journal { 'Journal of Test Articles' }
      year { 1920 }
    end

    factory :src_dmitriev do
      bibtex_type { 'article' }
      title { 'article 1 just title' }
      author { 'Dmitriev, Dmitry' }
      year { 1940 }
    end

    factory :src_editor do
      bibtex_type { 'article' }
      title { 'I am a soft valid article' }
      editor { 'Person, Test' }
      journal { 'Journal of Test Articles' }
      year { 1700 }

    end
  end
end
