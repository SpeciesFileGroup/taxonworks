FactoryGirl.define do
  factory :source_bibtex, class: Source::Bibtex, traits: [:creator_and_updater] do
    factory :valid_source_bibtex do
      bibtex_type 'article'
      title 'article 1 just title'
    end

    factory :soft_valid_bibtex_source_article do
      bibtex_type 'article'
      title 'I am a soft valid article'
      author 'Person, Test'
      journal 'Journal of test articles'
      year 1000
    end

    factory :valid_bibtex_source_book_title_only do
      bibtex_type 'book'
      title 'valid book with just a title'
    end

    factory :valid_thesis do
      bibtex_type 'phdthesis'
      title 'Bugs by Beth'
      author 'Jones, Beth'
      year 1982
      month 'jun'
    end

    factory :valid_misc do
      bibtex_type 'misc'
      title 'misc source'
      year 2010
      month 'jul'
      day 4
    end

    factory :src_mult_authors do
      bibtex_type 'article'
      title 'Article with multiple authors'
      author 'Thomas, Dave and Fowler, Chad and Hunt, Andy'
      journal 'Journal of test articles'
      year 1920
    end
   end
end
