FactoryGirl.define do

  factory :taxon_name do
  end

  factory :valid_taxon_name, class: TaxonName do
    association :parent, factory: :root_taxon_name
    name 'Adidae'
    rank_class Ranks.lookup(:iczn, 'Family')
  end

end
