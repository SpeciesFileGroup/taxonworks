FactoryGirl.define do
  factory :bibtex_source, class: 'Source::Bibtex' do
    bibtex_type 'article'
    title 'article 1 just title'
  end
end
