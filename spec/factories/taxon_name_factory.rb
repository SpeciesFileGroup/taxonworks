# Use protonym_factory for TaxonName factories.

FactoryGirl.define do
  factory :taxon_name, traits: [:housekeeping] do
    factory :valid_taxon_name, traits: [:housekeeping, :parent_is_root]  do
      name 'Adidae'
      rank_class Ranks.lookup(:iczn, 'Family')
    end
  end
end
