# Notes:
#  - type will be set to Protonym when not provided
#  - if you want to .create a protonym and not build the related ancestors ancestors set the parent to nil
FactoryGirl.define do

  factory :valid_protonym, class: Protonym do
    name 'Aidae'
    rank_class Ranks.lookup(:iczn, 'Family')
    association :parent, factory: :root_taxon_name
  end

  factory :protonym do
  end

  factory :root_taxon_name, class: Protonym do
    name 'Root'
    rank_class  NomenclaturalRank
    parent_id nil
  end

  # ICZN names

  factory :iczn_kingdom, class: Protonym do
    name 'Animalia'
    association :parent, factory: :root_taxon_name
    source nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:iczn, 'kingdom')
  end

  factory :iczn_phylum, class: Protonym do
    name 'Arthropoda'
    association :parent, factory: :iczn_kingdom
    source nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:iczn, 'phylum')
  end

  factory :iczn_class, class: Protonym do
    name 'Insecta'
    association :parent, factory: :iczn_phylum
    source nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:iczn, 'class')
  end


  factory :iczn_order, class: Protonym do
    name 'Hemiptera'
    association :parent, factory: :iczn_class
    source nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:iczn, 'order')
  end

  factory :iczn_family, class: Protonym do
    name 'Cicadellidae'
    association :parent, factory: :iczn_order
    association :source, factory: :valid_bibtex_source
    year_of_publication 1800
    verbatim_author 'Say'
    rank_class Ranks.lookup(:iczn, 'Family')
  end

  factory :iczn_subfamily, class: Protonym do
    name 'Typhlocybinae'
    association :parent, factory: :iczn_family
    association :source, factory: :valid_bibtex_source
    year_of_publication 1800
    verbatim_author 'Say'
    rank_class Ranks.lookup(:iczn, 'Subfamily')
  end

  factory :iczn_tribe, class: Protonym do
    name 'Erythroneurini'
    association :parent, factory: :iczn_subfamily
    association :source, factory: :valid_bibtex_source
    year_of_publication 1800
    verbatim_author 'Say'
    rank_class Ranks.lookup(:iczn, 'Tribe')
  end

  factory :iczn_subtribe, class: Protonym do
    name 'Aaina'
    association :parent, factory: :iczn_tribe
    association :source, factory: :valid_bibtex_source
    year_of_publication 1800
    verbatim_author 'Say'
    rank_class Ranks.lookup(:iczn, 'Tribe')
  end

  factory :iczn_genus, class: Protonym do
    name 'Erythroneura'
    association :parent, factory: :iczn_tribe
    association :source, factory: :valid_bibtex_source
    year_of_publication 1850
    verbatim_author 'Say'
    rank_class Ranks.lookup(:iczn, 'Genus')
  end

  factory :iczn_subgenus, class: Protonym do
    name 'Erythroneura'
    association :parent, factory: :iczn_genus
    association :source, factory: :valid_bibtex_source
    year_of_publication 1850
    verbatim_author 'Say'
    rank_class Ranks.lookup(:iczn, 'Subgenus')
  end

  factory :iczn_species, class: Protonym do
    name 'vitis'
    association :parent, factory: :iczn_subgenus
    association :source, factory: :valid_bibtex_source
    year_of_publication 1900
    verbatim_author 'McAtee'
    rank_class Ranks.lookup(:iczn, 'SPECIES')
  end

  factory :iczn_subspecies, class: Protonym do
    name 'ssp'
    association :parent, factory: :iczn_species
    association :source, factory: :valid_bibtex_source
    year_of_publication 1900
    verbatim_author 'McAtee'
    rank_class Ranks.lookup(:iczn, 'subspecies')
  end

  #ICN name

  factory :icn_kingdom, class: Protonym do
    name 'Plantae'
    association :parent, factory: :root_taxon_name
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'kingdom')
  end

  factory :icn_phylum, class: Protonym do
    name 'Aphyta'
    association :parent, factory: :icn_kingdom
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'phylum')
  end

  factory :icn_subphylum, class: Protonym do
    name 'Aphytina'
    association :parent, factory: :icn_phylum
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'subphylum')
  end

  factory :icn_class, class: Protonym do
    name 'Aopsida'
    association :parent, factory: :icn_subphylum
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'class')
  end

  factory :icn_subclass, class: Protonym do
    name 'Aidae'
    association :parent, factory: :icn_class
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'subclass')
  end

  factory :icn_order, class: Protonym do
    name 'Aales'
    association :parent, factory: :icn_subclass
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'order')
  end

  factory :icn_suborder, class: Protonym do
    name 'Aineae'
    association :parent, factory: :icn_order
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'suborder')
  end

  factory :icn_family, class: Protonym do
    name 'Aaceae'
    association :parent, factory: :icn_suborder
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'family')
  end

  factory :icn_subfamily, class: Protonym do
    name 'Aoideae'
    association :parent, factory: :icn_family
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'subfamily')
  end

  factory :icn_tribe, class: Protonym do
    name 'Aeae'
    association :parent, factory: :icn_subfamily
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'Tribe')
  end

  factory :icn_subtribe, class: Protonym do
    name 'Ainae'
    association :parent, factory: :icn_tribe
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'subtribe')
  end

  factory :icn_genus, class: Protonym do
    name 'Aus'
    association :parent, factory: :icn_subtribe
    source_id nil
    year_of_publication 1850
    verbatim_author 'John'
    rank_class Ranks.lookup(:icn, 'Genus')
  end

  factory :icn_subgenus, class: Protonym do
    name 'Aus'
    association :parent, factory: :icn_genus
    source_id nil
    year_of_publication 1850
    verbatim_author 'Say'
    rank_class Ranks.lookup(:icn, 'Subgenus')
  end

  factory :icn_section, class: Protonym do
    name 'Aus'
    association :parent, factory: :icn_subgenus
    source_id nil
    year_of_publication 1850
    verbatim_author 'Say'
    rank_class Ranks.lookup(:icn, 'section')
  end

  factory :icn_series, class: Protonym do
    name 'Aus'
    association :parent, factory: :icn_section
    source_id nil
    year_of_publication 1850
    verbatim_author 'Say'
    rank_class Ranks.lookup(:icn, 'series')
  end

  factory :icn_species, class: Protonym do
    name 'aaa'
    association :parent, factory: :icn_series
    source_id 10
    year_of_publication 1900
    verbatim_author 'McAtee'
    rank_class Ranks.lookup(:icn, 'SPECIES')
  end

  factory :icn_subspecies, class: Protonym do
    name 'bbb'
    association :parent, factory: :icn_species
    source_id 10
    year_of_publication 1900
    verbatim_author 'McAtee'
    rank_class Ranks.lookup(:icn, 'subspecies')
  end

  factory :icn_variety, class: Protonym do
    name 'ccc'
    association :parent, factory: :icn_subspecies
    source_id 10
    year_of_publication 1900
    verbatim_author 'McAtee'
    rank_class Ranks.lookup(:icn, 'variety')
  end

  # ICZN taxa for relationship validation

  factory :relationship_family, class: Protonym do
    name 'Erythroneuridae'
    association :parent, factory: :iczn_class
    year_of_publication 1850
    verbatim_author 'Say'
    rank_class Ranks.lookup(:iczn, 'family')
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

end
