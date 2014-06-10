# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :citation, traits: [:housekeeping] do
    factory :valid_citation do
      association :source, factory: :valid_source_bibtex
      association :citation_object, factory: :valid_otu
    end
  end
end
