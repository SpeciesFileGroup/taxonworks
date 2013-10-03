# This will guess the User class
FactoryGirl.define do
  factory :taxon_name do
    name "Aus"
    class_rank "NomenclaturalRank::ICZN::Governed::GenusGroup::Genus"
  end

  factory :order do
    TaxonNameID 1
    name "Hemiptera"
    parent_id nil
    cached_name nil
    cached_author_year nil
    cached_higher_classification "Hemiptera"
    original_description_source_id nil
    year_of_publication nil
    author nil
    rank_class "NomenclaturalRank::ICZN::Ungoverned::Order"
    type nil
  end

  factory :family do
    TaxonNameID 2
    name "Cicadellidae"
    parent_id :order
    cached_name nil
    cached_author_year nil
    cached_higher_classification "Hemiptera:Cicadellidae"
    original_description_source_id nil
    year_of_publication nil
    author nil
    rank_class "NomenclaturalRank::ICZN::Governed::FamilyGroup::Family"
    type nil
  end

  factory :subfamily do
    TaxonNameID 3
    name "Typhlocybinae"
    parent_id :family
    cached_name nil
    cached_author_year nil
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae"
    original_description_source_id nil
    year_of_publication nil
    author nil
    rank_class "NomenclaturalRank::ICZN::Governed::FamilyGroup::Subfamily"
    type nil
  end

  factory :tribe do
    TaxonNameID 4
    name "Erythroneurini"
    parent_id :subfamily
    cached_name nil
    cached_author_year nil
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id nil
    year_of_publication nil
    author nil
    rank_class "NomenclaturalRank::ICZN::Governed::FamilyGroup::Tribe"
    type nil
  end

  factory :subtribe do
    TaxonNameID 5
    name "Aaina"
    parent_id :tribe
    cached_name nil
    cached_author_year nil
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini:Aaina"
    original_description_source_id nil
    year_of_publication nil
    author nil
    rank_class "NomenclaturalRank::ICZN::Governed::FamilyGroup::Tribe"
    type nil
  end

  factory :genus do
    TaxonNameID 6
    name "Erythroneura"
    parent_id :tribe
    cached_name "Erythroneura"
    cached_author_year "Say, 1850"
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id nil
    year_of_publication 1850
    author "Say"
    rank_class "NomenclaturalRank::ICZN::Governed::GenusGroup::Genus"
    type nil
  end

  factory :subgenus do
    TaxonNameID 7
    name "Erythroneura"
    parent_id :genus
    cached_name "Erythroneura (Erythroneura)"
    cached_author_year "Say, 1850"
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id nil
    year_of_publication 1850
    author "Say"
    rank_class "NomenclaturalRank::ICZN::Governed::GenusGroup::Subgenus"
    type nil
  end

  factory :species do
    TaxonNameID 8
    name "aaa"
    parent_id :subgenus
    cached_name "Erythroneura (Erythroneura) aaa"
    cached_author_year "McAtee, 1900"
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id 10
    year_of_publication 1900
    author "McAtee"
    rank_class "NomenclaturalRank::ICZN::Governed::SpeciesGroup::Species"
    type nil
  end

  factory :subspecies do
    TaxonNameID 9
    name "bbb"
    parent_id :species
    cached_name "Erythroneura (Erythroneura) aaa bbb"
    cached_author_year "McAtee, 1900"
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id 10
    year_of_publication 1900
    author "McAtee"
    rank_class "NomenclaturalRank::ICZN::Governed::SpeciesGroup::Subspecies"
    type nil
  end

end
