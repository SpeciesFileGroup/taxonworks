# Notes:
#  - type will be set to Protonym when not provided
#  - if you want to .create a protonym and not build the related ancestors ancestors set the parent to nil
FactoryGirl.define do

  trait :mostly_empty_protonym do
    cached_name nil
    cached_author_year nil
    source_id nil
    year_of_publication nil
    verbatim_author nil
  end

  factory :protonym, traits: [:housekeeping, :mostly_empty_protonym] do

    factory :relationship_genus do
      name 'Erythroneura'
      association :parent, factory: :iczn_family
      year_of_publication 1850
      verbatim_author 'Say'
      rank_class Ranks.lookup(:iczn, 'Genus')
    end

    factory :relationship_species do
      name 'vitis'
      association :parent, factory: :relationship_genus
      source_id 10
      year_of_publication 1900
      verbatim_author 'McAtee'
      rank_class Ranks.lookup(:iczn, 'SPECIES')
    end

# ICZN taxa
    factory :valid_protonym do
      name 'Aidae'
      rank_class Ranks.lookup(:iczn, 'Family')
      association :parent, factory: :root_taxon_name
    end

    factory :root_taxon_name do
      name 'Root'
      rank_class  NomenclaturalRank
      parent_id nil
    end

    # ICZN names

    factory :iczn_kingdom, traits: [ ] do
      mostly_empty_protonym
      name 'Animalia'
      association :parent, factory: :root_taxon_name
      cached_higher_classification 'Animalia'
      rank_class Ranks.lookup(:iczn, 'kingdom')
    end

    factory :iczn_phylum do
      name 'Arthropoda'
      association :parent, factory: :iczn_kingdom
      cached_higher_classification 'Animalia:Arthropoda'
      rank_class Ranks.lookup(:iczn, 'phylum')
    end

    factory :iczn_class do
      name 'Insecta'
      association :parent, factory: :iczn_phylum
      cached_higher_classification 'Animalia:Arthropoda:Insecta'
      rank_class Ranks.lookup(:iczn, 'class')
    end

    factory :iczn_order do
      name 'Hemiptera'
      association :parent, factory: :iczn_class
      cached_higher_classification 'Animalia:Arthropoda:Insecta:Hemiptera'
      rank_class Ranks.lookup(:iczn, 'order')
    end

    factory :iczn_family do
      name 'Cicadellidae'
      association :parent, factory: :iczn_order
      cached_higher_classification 'Animalia:Arthropoda:Insecta:Hemiptera:Cicadellidae'
      rank_class Ranks.lookup(:iczn, 'Family')
    end

    factory :iczn_subfamily do
      name 'Typhlocybinae'
      association :parent, factory: :iczn_family
      cached_higher_classification 'Animalia:Arthropoda:Insecta:Hemiptera:Cicadellidae:Typhlocybinae'
      rank_class Ranks.lookup(:iczn, 'Subfamily')
    end

    factory :iczn_tribe do
      name 'Erythroneurini'
      association :parent, factory: :iczn_subfamily
      cached_higher_classification 'Animalia:Arthropoda:Insecta:Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini'
      rank_class Ranks.lookup(:iczn, 'Tribe')
    end

    factory :iczn_subtribe do
      name 'Aaina'
      association :parent, factory: :iczn_tribe
      cached_higher_classification 'Animalia:Arthropoda:Insecta:Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini:Aaina'
      rank_class Ranks.lookup(:iczn, 'Tribe')
    end

    factory :iczn_genus do
      name 'Erythroneura'
      association :parent, factory: :iczn_tribe
      cached_name 'Erythroneura'
      cached_author_year 'Say, 1850'
      cached_higher_classification 'Animalia:Arthropoda:Insecta:Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini'
      year_of_publication 1850
      verbatim_author 'Say'
      rank_class Ranks.lookup(:iczn, 'Genus')
    end

    factory :iczn_subgenus do
      name 'Erythroneura'
      association :parent, factory: :iczn_genus
      cached_name 'Erythroneura (Erythroneura)'
      cached_author_year 'Say, 1850'
      cached_higher_classification 'Animalia:Arthropoda:Insecta:Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini'
      year_of_publication 1850
      verbatim_author 'Say'
      rank_class Ranks.lookup(:iczn, 'Subgenus')
    end

    factory :iczn_species do
      name 'vitis'
      association :parent, factory: :iczn_subgenus
      cached_name 'Erythroneura (Erythroneura) aaa'
      cached_author_year 'McAtee, 1900'
      cached_higher_classification 'Animalia:Arthropoda:Insecta:Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini'
      association :source, factory: :valid_bibtex_source
      year_of_publication 1900
      verbatim_author 'McAtee'
      rank_class Ranks.lookup(:iczn, 'SPECIES')
    end

    factory :iczn_subspecies do
      name 'ssp'
      association :parent, factory: :iczn_species
      cached_name 'Erythroneura (Erythroneura) vitis ssp'
      cached_author_year 'McAtee, 1900'
      cached_higher_classification 'Animalia:Arthropoda:Insecta:Hemiptera:Cicadellidae:Typhlocybinae:Erythroneurini'
      source_id 10
      year_of_publication 1900
      verbatim_author 'McAtee'
      rank_class Ranks.lookup(:iczn, 'subspecies')
    end

    #ICN name

    factory :icn_kingdom do
      name 'Plantae'
      association :parent, factory: :root_taxon_name
      cached_higher_classification 'Plantae'
      rank_class Ranks.lookup(:icn, 'kingdom')
    end

    factory :icn_phylum do
      name 'Aphyta'
      association :parent, factory: :icn_kingdom
      cached_higher_classification 'Plantae:Aphyta'
      rank_class Ranks.lookup(:icn, 'phylum')
    end

    factory :icn_subphylum do
      name 'Aphytina'
      association :parent, factory: :icn_phylum
      cached_higher_classification 'Plantae:Aphyta:Aphytina'
      rank_class Ranks.lookup(:icn, 'subphylum')
    end

    factory :icn_class do
      name 'Aopsida'
      association :parent, factory: :icn_subphylum
      cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida'
      rank_class Ranks.lookup(:icn, 'class')
    end

    factory :icn_subclass do
      name 'Aidae'
      association :parent, factory: :icn_class
      cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae'
      rank_class Ranks.lookup(:icn, 'subclass')
    end

    factory :icn_order do
      name 'Aales'
      association :parent, factory: :icn_subclass
      cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales'
      rank_class Ranks.lookup(:icn, 'order')
    end

    factory :icn_suborder do
      name 'Aineae'
      association :parent, factory: :icn_order
      cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae'
      rank_class Ranks.lookup(:icn, 'suborder')
    end

    factory :icn_family do
      name 'Aaceae'
      association :parent, factory: :icn_suborder
      cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae'
      rank_class Ranks.lookup(:icn, 'family')
    end

    factory :icn_subfamily do
      name 'Aoideae'
      association :parent, factory: :icn_family
      cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae'
      rank_class Ranks.lookup(:icn, 'subfamily')
    end

    factory :icn_tribe do
      name 'Aeae'
      association :parent, factory: :icn_subfamily
      cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae:Aeae'
      rank_class Ranks.lookup(:icn, 'Tribe')
    end

    factory :icn_subtribe do
      name 'Ainae'
      association :parent, factory: :icn_tribe
      cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae:Aeae:Ainae'
      rank_class Ranks.lookup(:icn, 'subtribe')
    end

    factory :icn_genus do
      name 'Aus'
      association :parent, factory: :icn_subtribe
      cached_name 'Aus'
      cached_author_year 'Say (1850)'
      cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae:Aeae:Ainae'
      year_of_publication 1850
      verbatim_author 'John'
      rank_class Ranks.lookup(:icn, 'Genus')
    end

    factory :icn_subgenus do
      name 'Aus'
      association :parent, factory: :icn_genus
      cached_name 'Aus (Aus)'
      cached_author_year 'Say (1850)'
      cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae:Aeae:Ainae'
      year_of_publication 1850
      verbatim_author 'Say'
      rank_class Ranks.lookup(:icn, 'Subgenus')
    end

    factory :icn_section do
      name 'Aus'
      association :parent, factory: :icn_subgenus
      cached_name 'Aus (Aus sect. Aus)'
      cached_author_year 'Say (1850)'
      cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae:Aeae:Ainae'
      year_of_publication 1850
      verbatim_author 'Say'
      rank_class Ranks.lookup(:icn, 'section')
    end

    factory :icn_series do
      name 'Aus'
      association :parent, factory: :icn_section
      cached_name 'Aus (Aus sect. Aus ser. Aus)'
      cached_author_year 'Say (1850)'
      cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae:Aeae:Ainae'
      year_of_publication 1850
      verbatim_author 'Say'
      rank_class Ranks.lookup(:icn, 'series')
    end


    factory :icn_species do
      name 'aaa'
      association :parent, factory: :icn_series
      cached_name 'Aus (Aus sect. Aus ser. Aus) aaa'
      cached_author_year 'McAtee (1900)'
      cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae:Aeae:Ainae'
      source_id 10
      year_of_publication 1900
      verbatim_author 'McAtee'
      rank_class Ranks.lookup(:icn, 'SPECIES')
    end

    factory :icn_subspecies do
      name 'bbb'
      association :parent, factory: :icn_species
      cached_name 'Aus (Aus sect. Aus ser. Aus) aaa bbb'
      cached_author_year 'McAtee (1900)'
      cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae:Aeae:Ainae'
      source_id 10
      year_of_publication 1900
      verbatim_author 'McAtee'
      rank_class Ranks.lookup(:icn, 'subspecies')
    end

    factory :icn_variety do
      name 'ccc'
      association :parent, factory: :icn_subspecies
      cached_name 'Aus (Aus sect. Aus ser. Aus) aaa bbb var. ccc'
      cached_author_year 'McAtee (1900)'
      cached_higher_classification 'Plantae:Aphyta:Aphytina:Aopsida:Aidae:Aales:Aineae:Aaceae:Aoideae:Aeae:Ainae'
      source_id 10
      year_of_publication 1900
      verbatim_author 'McAtee'
      rank_class Ranks.lookup(:icn, 'variety')
    end
  end



end
