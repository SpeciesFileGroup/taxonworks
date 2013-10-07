FactoryGirl.define do
  factory :taxon_name, class: TaxonName do
    name "Aus"
    rank_class Ranks.lookup(:iczn, "genus")
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
    rank_class Ranks.lookup(:iczn, "order")
    type nil
  end

  factory :family, class: TaxonName do
    name "Cicadellidae"
    #parent_id :order FIXME
    cached_name nil
    cached_author_year nil
    cached_higher_classification "Hemiptera:Cicadellidae"
    original_description_source_id nil
    year_of_publication nil
    author nil
    rank_class Ranks.lookup(:iczn, "Family")
    type nil
  end

  factory :subfamily, class: TaxonName do
    name "Typhlocybinae"
    #parent_id :family FIXME
    cached_name nil
    cached_author_year nil
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae"
    original_description_source_id nil
    year_of_publication nil
    author nil
    rank_class Ranks.lookup(:iczn, "Subfamily")
    type nil
  end

  factory :tribe, class: TaxonName do
    name "Erythroneurini"
    #parent_id :subfamily FIXME
    cached_name nil
    cached_author_year nil
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id nil
    year_of_publication nil
    author nil
    rank_class Ranks.lookup(:iczn, "Tribe")
    type nil
  end

  factory :subtribe, class: TaxonName do
    name "Aainaini" # TODO: Used to be "Aaina", added suffix "ini" to make the validation pass, please review logic or just delete this comment if previous value was incorrect
    #parent_id :tribe FIXME
    cached_name nil
    cached_author_year nil
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini:Aaina"
    original_description_source_id nil
    year_of_publication nil
    author nil
    rank_class Ranks.lookup(:iczn, "Tribe")
    type nil
  end

  factory :genus, class: TaxonName do
    name "Erythroneura"
    #parent_id :tribe FIXME
    cached_name "Erythroneura"
    cached_author_year "Say, 1850"
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id nil
    year_of_publication 1850
    author "Say"
    rank_class Ranks.lookup(:iczn, "Genus")
    type nil
  end

  factory :subgenus, class: TaxonName do
    name "Erythroneura"
    #parent_id :genus FIXME
    cached_name "Erythroneura (Erythroneura)"
    cached_author_year "Say, 1850"
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id nil
    year_of_publication 1850
    author "Say"
    rank_class Ranks.lookup(:iczn, "Subgenus")
    type nil
  end

  factory :species, class: TaxonName do
    name "aaa"
    #parent_id :subgenus FIXME
    cached_name "Erythroneura (Erythroneura) aaa"
    cached_author_year "McAtee, 1900"
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id 10
    year_of_publication 1900
    author "McAtee"
    rank_class Ranks.lookup(:iczn, "Species")
    type nil
  end

  factory :subspecies, class: TaxonName do
    name "bbb"
    #parent_id :species FIXME
    cached_name "Erythroneura (Erythroneura) aaa bbb"
    cached_author_year "McAtee, 1900"
    cached_higher_classification "Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini"
    original_description_source_id 10
    year_of_publication 1900
    author "McAtee"
    rank_class Ranks.lookup(:iczn, "Subspecies")
    type nil
  end

end
