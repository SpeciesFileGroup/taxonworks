FactoryGirl.define do
  factory :taxon_name_classification, traits: [:housekeeping] do
    factory :valid_taxon_name_classification do
      association :taxon_name, factory: :valid_protonym
      type 'TaxonNameClassification::Iczn::Unavailable'
    end
  end
end
