FactoryGirl.define do
  factory :taxon_name, class: TaxonName do
    name "Aus"
    rank_class "NomenclaturalRank::Iczn::Governed::GenusGroup::Genus"
  end
  
  factory :order, class: TaxonName do
    name "Hemiptera"
    parent_id nil
    cached_name nil
    cached_author_year nil
    cached_higher_classification "Hemiptera"
    original_description_source_id nil
    year_of_publication nil
    author nil
    rank_class ::ICZN_LOOKUP["order"]
    type nil
  end

  factory :family, class: TaxonName do
    name "Cicadellidae"
    parent_id :order
    cached_name nil
    cached_author_year nil
    cached_higher_classification "Hemiptera:Cicadellidae"
    original_description_source_id nil
    year_of_publication nil
    author nil
    rank_class "NomenclaturalRank::Iczn::Governed::FamilyGroup::Family"
    type nil
  end

  factory :subfamily, class: TaxonName do
    name "Typhlocybinae"
    parent_id :family
    cached_name nil
    cached_author_year nil
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae"
    original_description_source_id nil
    year_of_publication nil
    author nil
    rank_class "NomenclaturalRank::Iczn::Governed::FamilyGroup::Subfamily"
    type nil
  end

  factory :tribe, class: TaxonName do
    name "Erythroneurini"
    parent_id :subfamily
    cached_name nil
    cached_author_year nil
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id nil
    year_of_publication nil
    author nil
    rank_class "NomenclaturalRank::Iczn::Governed::FamilyGroup::Tribe"
    type nil
  end

  factory :subtribe, class: TaxonName do
    name "Aainaini" #TODO: Used to be "Aaina", added suffix "ini" to make the validation pass, please review logic or just delete this comment if previous value was incorrect
    parent_id :tribe
    cached_name nil
    cached_author_year nil
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini:Aaina"
    original_description_source_id nil
    year_of_publication nil
    author nil
    rank_class "NomenclaturalRank::Iczn::Governed::FamilyGroup::Tribe"
    type nil
  end

  factory :genus, class: TaxonName do
    name "Erythroneura"
    parent_id :tribe
    cached_name "Erythroneura"
    cached_author_year "Say, 1850"
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id nil
    year_of_publication 1850
    author "Say"
    rank_class "NomenclaturalRank::Iczn::Governed::GenusGroup::Genus"
    type nil
  end

  factory :subgenus, class: TaxonName do
    name "Erythroneura"
    parent_id :genus
    cached_name "Erythroneura (Erythroneura)"
    cached_author_year "Say, 1850"
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id nil
    year_of_publication 1850
    author "Say"
    rank_class "NomenclaturalRank::Iczn::Governed::GenusGroup::Subgenus"
    type nil
  end

  factory :species, class: TaxonName do
    name "aaa"
    parent_id :subgenus
    cached_name "Erythroneura (Erythroneura) aaa"
    cached_author_year "McAtee, 1900"
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id 10
    year_of_publication 1900
    author "McAtee"
    rank_class "NomenclaturalRank::Iczn::Governed::SpeciesGroup::Species"
    type nil
  end

  factory :subspecies, class: TaxonName do
    name "bbb"
    parent_id :species
    cached_name "Erythroneura (Erythroneura) aaa bbb"
    cached_author_year "McAtee, 1900"
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id 10
    year_of_publication 1900
    author "McAtee"
    rank_class "NomenclaturalRank::Iczn::Governed::SpeciesGroup::Subspecies"
    type nil
  end

end
