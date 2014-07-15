FactoryGirl.define do
  factory :source, traits: [:creator_and_updater]  do
    factory :valid_source do
      bibtex_type 'article'
      title 'article 1 just title'
      type 'Source::Bibtex'
    end
  end
end
