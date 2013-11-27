FactoryGirl.define do

  factory :taxon_name_relationship, class: 'TaxonNameRelationship' do
  end

  # ICZN taxa

  factory :relationship_family, class: Protonym do
    name 'Erythroneuridae'
    rank_class Ranks.lookup(:iczn, 'Family')
  end

  factory :relationship_genus, class: Protonym do
    name 'Erythroneura'
    association :parent, factory: :relationship_family
    year_of_publication 1850
    verbatim_author 'Say'
    rank_class Ranks.lookup(:iczn, 'Genus')
  end

  factory :relationship_species, class: 'Protonym' do
    name 'vitis'
    association :parent, factory: :relationship_genus
    source_id 10
    year_of_publication 1900
    verbatim_author 'McAtee'
    rank_class Ranks.lookup(:iczn, 'SPECIES')
  end

  #relationships

  factory :type_genus_relationship, class: 'TaxonNameRelationship' do
    association :subject, factory: :relationship_genus
    association :object, factory: :relationship_family
    type TaxonNameRelationship::Typification::Family
  end

  factory :type_species_relationship, class: 'TaxonNameRelationship' do
    association :subject, factory: :relationship_species
    association :object, factory: :relationship_genus
    type TaxonNameRelationship::Typification::Genus::Monotypy::Original
  end



end
