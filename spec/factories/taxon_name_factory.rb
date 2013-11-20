FactoryGirl.define do

  factory :taxon_name do
  end

  factory :valid_taxon_name do
    name 'Adidae'
    rank rank_class: Ranks.lookup(:iczn, 'family')
  end

end
