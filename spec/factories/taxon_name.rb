FactoryGirl.define do

#  factory :iczn_taxon_name, class: Protonym do
#    name 'Aus'
#    rank_class Ranks.lookup(:iczn, 'genus')
#  end

  factory :root_taxon_name, class: Protonym do
    name 'Root'
    rank_class  NomenclaturalRank
    parent_id nil
  end

  #  use parent rather than parent_id parent should use an association to a factory generator. 
  
  # ICZN names

  factory :iczn_kingdom, class: Protonym do
    name 'Animalia'
    association :parent, factory: :root_taxon_name
    cached_name nil
    cached_author_year nil
    cached_higher_classification 'Animalia'
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:iczn, 'kingdom')
    type 'Protonym'
  end

  factory :iczn_phylum, class: Protonym do
    name 'Arthropoda'
    association :parent, factory: :iczn_kingdom
    cached_name nil
    cached_author_year nil
    cached_higher_classification 'Animalia:Arthropoda'
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:iczn, 'phylum')
    type 'Protonym'
  end

  factory :iczn_class, class: Protonym do
    name 'Insecta'
    association :parent, factory: :iczn_phylum
    cached_name nil
    cached_author_year nil
    cached_higher_classification 'Animalia:Arthropoda:Insecta'
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:iczn, 'class')
    type 'Protonym'
  end


  factory :iczn_order, class: Protonym do
    name 'Hemiptera'
    association :parent, factory: :iczn_class
    cached_name nil
    cached_author_year nil
    cached_higher_classification 'Animalia:Arthropoda:Insecta:Hemiptera'
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:iczn, 'order')
    type 'Protonym'
  end

  factory :iczn_family, class: Protonym do
    name 'Cicadellidae'
    association :parent, factory: :iczn_order
    cached_name nil
    cached_author_year nil
    cached_higher_classification 'Animalia:Arthropoda:Insecta:Hemiptera:Cicadellidae'
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:iczn, 'Family')
    type 'Protonym'
  end

  factory :iczn_subfamily, class: Protonym do
    name 'Typhlocybinae'
    association :parent, factory: :iczn_family
    cached_name nil
    cached_author_year nil
    cached_higher_classification 'Animalia:Arthropoda:Insecta:Hemiptera:Cicadellidae:Typhlocybinae'
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:iczn, 'Subfamily')
    type 'Protonym'
  end

  factory :iczn_tribe, class: Protonym do
    name 'Erythroneurini'
    association :parent, factory: :iczn_subfamily
    cached_name nil
    cached_author_year nil
    cached_higher_classification 'Animalia:Arthropoda:Insecta:Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini'
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:iczn, 'Tribe')
    type 'Protonym'
  end

  factory :iczn_subtribe, class: Protonym do
    name 'Aaina'
    association :parent, factory: :iczn_tribe
    cached_name nil
    cached_author_year nil
    cached_higher_classification 'Animalia:Arthropoda:Insecta:Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini:Aaina'
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:iczn, 'Tribe')
    type 'Protonym'
  end

  factory :iczn_genus, class: Protonym do
    name 'Erythroneura'
    association :parent, factory: :iczn_tribe
    cached_name 'Erythroneura'
    cached_author_year 'Say, 1850'
    cached_higher_classification 'Animalia:Arthropoda:Insecta:Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini'
    source_id nil
    year_of_publication 1850
    verbatim_author 'Say'
    rank_class Ranks.lookup(:iczn, 'Genus')
    type 'Protonym'
  end

  factory :iczn_subgenus, class: Protonym do
    name 'Erythroneura'
    association :parent, factory: :iczn_genus
    cached_name 'Erythroneura (Erythroneura)'
    cached_author_year 'Say, 1850'
    cached_higher_classification 'Animalia:Arthropoda:Insecta:Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini'
    source_id nil
    year_of_publication 1850
    verbatim_author 'Say'
    rank_class Ranks.lookup(:iczn, 'Subgenus')
    type 'Protonym'
  end

  factory :iczn_species, class: Protonym do
    name 'aaa'
    association :parent, factory: :iczn_subgenus
    cached_name 'Erythroneura (Erythroneura) aaa'
    cached_author_year 'McAtee, 1900'
    cached_higher_classification 'Animalia:Arthropoda:Insecta:Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini'
    source_id 10
    year_of_publication 1900
    verbatim_author 'McAtee'
    rank_class Ranks.lookup(:iczn, 'SPECIES')
    type 'Protonym'
  end

  factory :iczn_subspecies, class: Protonym do
    name 'bbb'
    association :parent, factory: :iczn_species
    cached_name 'Erythroneura (Erythroneura) aaa bbb'
    cached_author_year 'McAtee, 1900'
    cached_higher_classification 'Animalia:Arthropoda:Insecta:Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini'
    source_id 10
    year_of_publication 1900
    verbatim_author 'McAtee'
    rank_class Ranks.lookup(:iczn, 'subspecies')
    type 'Protonym'
  end

  
  #ICN name

  factory :icn_kingdom, class: Protonym do
    name 'Plantae'
    association :parent, factory: :root_taxon_name
    cached_name nil
    cached_author_year nil
    cached_higher_classification 'Plantae'
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'kingdom')
    type 'Protonym'
  end

  factory :icn_phylum, class: Protonym do
    name 'Aphyta'
    association :parent, factory: :icn_kingdom
    cached_name nil
    cached_author_year nil
    cached_higher_classification 'Plantae:Aphyta'
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'phylum')
    type 'Protonym'
  end

  factory :icn_subphylum, class: Protonym do
    name 'Aphytina'
    association :parent, factory: :icn_phylum
    cached_name nil
    cached_author_year nil
    cached_higher_classification 'Plantae:Aphyta:Aphytina'
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'subphylum')
    type 'Protonym'
  end

  factory :icn_class, class: Protonym do
    name 'Aopsida'
    association :parent, factory: :icn_subphylum
    cached_name nil
    cached_author_year nil
    cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida'
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'class')
    type 'Protonym'
  end

  factory :icn_subclass, class: Protonym do
    name 'Aidae'
    association :parent, factory: :icn_class
    cached_name nil
    cached_author_year nil
    cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae'
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'subclass')
    type 'Protonym'
  end

  factory :icn_order, class: Protonym do
    name 'Aales'
    association :parent, factory: :icn_subclass
    cached_name nil
    cached_author_year nil
    cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales'
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'order')
    type 'Protonym'
  end

  factory :icn_suborder, class: Protonym do
    name 'Aineae'
    association :parent, factory: :icn_order
    cached_name nil
    cached_author_year nil
    cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae'
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'suborder')
    type 'Protonym'
  end

  factory :icn_family, class: Protonym do
    name 'Aaceae'
    association :parent, factory: :icn_suborder
    cached_name nil
    cached_author_year nil
    cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae'
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'family')
    type 'Protonym'
  end

  factory :icn_subfamily, class: Protonym do
    name 'Aoideae'
    association :parent, factory: :icn_family
    cached_name nil
    cached_author_year nil
    cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae'
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'subfamily')
    type 'Protonym'
  end

  factory :icn_tribe, class: Protonym do
    name 'Aeae'
    association :parent, factory: :icn_subfamily
    cached_name nil
    cached_author_year nil
    cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae:Aeae'
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'Tribe')
    type 'Protonym'
  end

  factory :icn_subtribe, class: Protonym do
    name 'Ainae'
    association :parent, factory: :icn_tribe
    cached_name nil
    cached_author_year nil
    cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae:Aeae:Ainae'
    source_id nil
    year_of_publication nil
    verbatim_author nil
    rank_class Ranks.lookup(:icn, 'subtribe')
    type 'Protonym'
  end

  factory :icn_genus, class: Protonym do
    name 'Aus'
    association :parent, factory: :icn_subtribe
    cached_name 'Erythroneura'
    cached_author_year 'Say (1850)'
    cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae:Aeae:Ainae'
    source_id nil
    year_of_publication 1850
    verbatim_author 'John'
    rank_class Ranks.lookup(:icn, 'Genus')
    type 'Protonym'
  end

  factory :icn_subgenus, class: Protonym do
    name 'Aus'
    association :parent, factory: :icn_genus
    cached_name 'Aus (Aus)'
    cached_author_year 'Say (1850)'
    cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae:Aeae:Ainae'
    source_id nil
    year_of_publication 1850
    verbatim_author 'Say'
    rank_class Ranks.lookup(:icn, 'Subgenus')
    type 'Protonym'
  end

  factory :icn_section, class: Protonym do
    name 'Aus'
    association :parent, factory: :icn_subgenus
    cached_name 'Aus (Aus sect. Aus)'
    cached_author_year 'Say (1850)'
    cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae:Aeae:Ainae'
    source_id nil
    year_of_publication 1850
    verbatim_author 'Say'
    rank_class Ranks.lookup(:icn, 'section')
    type 'Protonym'
  end

  factory :icn_series, class: Protonym do
    name 'Aus'
    association :parent, factory: :icn_section
    cached_name 'Aus (Aus sect. Aus ser. Aus)'
    cached_author_year 'Say (1850)'
    cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae:Aeae:Ainae'
    source_id nil
    year_of_publication 1850
    verbatim_author 'Say'
    rank_class Ranks.lookup(:icn, 'series')
    type 'Protonym'
  end


  factory :icn_species, class: Protonym do
    name 'aaa'
    association :parent, factory: :icn_section
    cached_name 'Aus (Aus sect. Aus ser. Aus) aaa'
    cached_author_year 'McAtee (1900)'
    cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae:Aeae:Ainae'
    source_id 10
    year_of_publication 1900
    verbatim_author 'McAtee'
    rank_class Ranks.lookup(:icn, 'SPECIES')
    type 'Protonym'
  end

  factory :icn_subspecies, class: Protonym do
    name 'bbb'
    association :parent, factory: :icn_species
    cached_name 'Aus (Aus sect. Aus ser. Aus) aaa bbb'
    cached_author_year 'McAtee (1900)'
    cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae:Aeae:Ainae'
    source_id 10
    year_of_publication 1900
    verbatim_author 'McAtee'
    rank_class Ranks.lookup(:icn, 'subspecies')
    type 'Protonym'
  end

  factory :icn_variety, class: Protonym do
    name 'ccc'
    association :parent, factory: :icn_subspecies
    cached_name 'Aus (Aus sect. Aus ser. Aus) aaa bbb var. ccc'
    cached_author_year 'McAtee (1900)'
    cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae:Aeae:Ainae'
    source_id 10
    year_of_publication 1900
    verbatim_author 'McAtee'
    rank_class Ranks.lookup(:icn, 'variety')
    type 'Protonym'
  end

end
