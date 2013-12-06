FactoryGirl.define do
  factory :bibtex_source, class: Source::Bibtex, traits: [:creator_and_updater] do 
    factory :valid_bibtex_source do
      bibtex_type 'article'
      title 'article 1 just title'
    end

    factory :valid_bibtex_source_book_title_only do
      bibtex_type 'book'
      title 'valid book with just a title'
    end
  end
end
