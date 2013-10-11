FactoryGirl.define do

  factory :iczn_taxon_name, class: Protonym do
    name "Aus"
    rank_class Ranks.lookup(:iczn, "genus")
  end

  factory :root_taxon_name, class: Protonym do
    name "Root"
    rank_class  NomenclaturalRank
    parent_id nil
  end

  # TODO: use parent rather than parent_id parent should use an association to a factory generator. 
  factory :iczn_order, class: Protonym do
    name "Hemiptera"
    parent nil
    cached_name nil
    cached_author_year nil
    cached_higher_classification "Hemiptera"
    original_description_source_id nil
    year_of_publication nil
    author nil
    rank_class Ranks.lookup(:iczn, "order")
    type nil
  end

  factory :iczn_family, class: Protonym do
    name "Cicadellidae"
    association :parent, factory: :iczn_order
    cached_name nil
    cached_author_year nil
    cached_higher_classification "Hemiptera:Cicadellidae"
    original_description_source_id nil
    year_of_publication nil
    author nil
    rank_class Ranks.lookup(:iczn, "Family")
    type nil
  end

  factory :iczn_subfamily, class: Protonym do
    name "Typhlocybinae"
    association :parent, factory: :iczn_family
    cached_name nil
    cached_author_year nil
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae"
    original_description_source_id nil
    year_of_publication nil
    author nil
    rank_class Ranks.lookup(:iczn, "Subfamily")
    type nil
  end

  factory :iczn_tribe, class: Protonym do
    name "Erythroneurini"
    association :parent, factory: :iczn_subfamily
    cached_name nil
    cached_author_year nil
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id nil
    year_of_publication nil
    author nil
    rank_class Ranks.lookup(:iczn, "Tribe")
    type nil
  end

  factory :iczn_subtribe, class: Protonym do
    name "Aainaini" # TODO: Used to be "Aaina", added suffix "ini" to make the validation pass, please review logic or just delete this comment if previous value was incorrect
    association :parent, factory: :iczn_tribe
    cached_name nil
    cached_author_year nil
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini:Aaina"
    original_description_source_id nil
    year_of_publication nil
    author nil
    rank_class Ranks.lookup(:iczn, "Tribe")
    type nil
  end

  factory :iczn_genus, class: Protonym do
    name "Erythroneura"
    association :parent, factory: :iczn_tribe
    cached_name "Erythroneura"
    cached_author_year "Say, 1850"
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id nil
    year_of_publication 1850
    author "Say"
    rank_class Ranks.lookup(:iczn, "Genus")
    type nil
  end

  factory :iczn_subgenus, class: Protonym do
    name "Erythroneura"
    association :parent, factory: :iczn_genus
    cached_name "Erythroneura (Erythroneura)"
    cached_author_year "Say, 1850"
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id nil
    year_of_publication 1850
    author "Say"
    rank_class Ranks.lookup(:iczn, "Subgenus")
    type nil
  end

  factory :iczn_species, class: Protonym do
    name "aaa"
    association :parent, factory: :iczn_subgenus
    cached_name "Erythroneura (Erythroneura) aaa"
    cached_author_year "McAtee, 1900"
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id 10
    year_of_publication 1900
    author "McAtee"
    rank_class Ranks.lookup(:iczn, "SPECIES")
    type nil
  end

  factory :iczn_subspecies, class: Protonym do
    name "bbb"
    association :parent, factory: :iczn_species
    cached_name "Erythroneura (Erythroneura) aaa bbb"
    cached_author_year "McAtee, 1900"
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id 10
    year_of_publication 1900
    author "McAtee"
    rank_class Ranks.lookup(:iczn, "subspecies")
    type nil
  end

end
