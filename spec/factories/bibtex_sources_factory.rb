FactoryGirl.define do

  factory :bibtex_source_base, class: Source::Bibtex do

    ignore do
        
    end

      association :creator, factory: :valid_user, strategy: :build
      association :updater, factory: :valid_user, strategy: :build
      association :project, factory: :valid_project, strategy: :build

      factory :bibtex_source, class: 'Source::Bibtex' do
      end

    factory :valid_bibtex_source, class: 'Source::Bibtex' do
      bibtex_type 'article'
      title 'article 1 just title'
    end

    factory :valid_bibtex_source_book_title_only, class: 'Source::Bibtex' do
      bibtex_type 'book'
      title 'valid book with just a title'
    end
  end
end
