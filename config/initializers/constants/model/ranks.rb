# Be sure to restart your server when you modify this file.

Rails.application.reloader.to_prepare do

  # Crossreference with http://api.col.plus/vocab/nomcode

  # !! All constants are now composed of Strings only.  They must not reference a class. !!
  #
  # Contains NOMEN classes of rank/hierarchy in various format.
  #
  # ICN, ICZN, ICNP class names ordered in an Array
  ICN ||= NomenclaturalRank::Icn.ordered_ranks.map(&:to_s).freeze
  ICZN ||= NomenclaturalRank::Iczn.ordered_ranks.map(&:to_s).freeze
  ICNP ||= NomenclaturalRank::Icnp.ordered_ranks.map(&:to_s).freeze
  ICVCN ||= NomenclaturalRank::Icvcn.ordered_ranks.map(&:to_s).freeze

  # All assignable Rank Classes
  RANKS ||= ( ['NomenclaturalRank'] + ICN + ICZN + ICNP + ICVCN).freeze

  RANK_SORT ||= RANKS.each_with_index.inject({}){|hsh, a| hsh[a.first] = a.last; hsh}.freeze

  ri = {}

  [['NomenclaturalRank'], ICN, ICZN, ICNP, ICVCN].each do |g|
    g.each_with_index do |r, i|
      ri[r] = i
    end
  end

  RANK_INDENT ||= ri.freeze

  # ICN Rank Classes in a Hash with keys being the "human" name
  # For example, to return the class for a plant family:
  #   ::ICN_LOOKUP['family']
  ICN_LOOKUP ||= ICN.inject({}){|hsh, r| hsh.merge!(r.constantize.rank_name => r)}.freeze

  #   ::ICNP_LOOKUP['family']
  ICNP_LOOKUP ||= ICNP.inject({}){|hsh, r| hsh.merge!(r.constantize.rank_name => r)}.freeze

  #   ::ICVCN_LOOKUP['family']
  ICVCN_LOOKUP ||= ICVCN.inject({}){|hsh, r| hsh.merge!(r.constantize.rank_name => r)}.freeze

  # ICZN Rank Classes in a Hash with keys being the "human" name
  ICZN_LOOKUP ||= ICZN.inject({}){|hsh, r| hsh.merge!(r.constantize.rank_name => r)}.freeze

  # All ranks, with keys as class strings pointing to common usage
  RANKS_LOOKUP ||= ICN_LOOKUP.invert.merge(ICZN_LOOKUP.invert.merge(ICNP_LOOKUP.invert.merge(ICVCN_LOOKUP.invert))).freeze

  # An Array of Arrays, used in options for select
  #   [["class (ICN)", "NomenclaturalRank::Icn::HigherClassificationGroup::ClassRank"] .. ]
  RANKS_SELECT_OPTIONS ||= RANKS_LOOKUP.collect{|k,v|
    ["#{v} " + ((k.to_s =~ /Iczn/) ? '(ICZN)' : ((k.to_s =~ /Icnp/) ? '(ICNP)' : ((k.to_s =~ /Icvcn/) ? '(ICVCN)' : '(ICN)')) ), k, {class: ((k.to_s =~ /Iczn/) ? :iczn : ((k.to_s =~ /Icnp/) ? :icnp : ((k.to_s =~ /Icvcn/) ? :icvcn : :icn))) }] }.sort{|a, b| a[0] <=> b[0]}.freeze

  # All assignable ranks for family groups, for ICZN, ICN, ICNP
  FAMILY_RANK_NAMES_ICZN ||= NomenclaturalRank::Iczn::FamilyGroup.descendants.map(&:to_s).freeze
  FAMILY_RANK_NAMES_ICN ||= NomenclaturalRank::Icn::FamilyGroup.descendants.map(&:to_s).freeze
  FAMILY_RANK_NAMES_ICNP ||= NomenclaturalRank::Icnp::FamilyGroup.descendants.map(&:to_s).freeze
  FAMILY_RANK_NAMES_ICVCN ||= ['NomenclaturalRank::Icvcn::Family', 'NomenclaturalRank::Icvcn::Subfamily'].freeze

  # All assignable ranks for family group, for ICN, ICNP, and ICZN
  FAMILY_RANK_NAMES ||=  ( FAMILY_RANK_NAMES_ICZN + FAMILY_RANK_NAMES_ICN + FAMILY_RANK_NAMES_ICNP + FAMILY_RANK_NAMES_ICVCN).freeze

  # All assignable higher ranks for family group, for ICN, ICNP, and ICZN
  HIGHER_RANK_NAMES_ICZN ||= NomenclaturalRank::Iczn::HigherClassificationGroup.descendants.map(&:to_s).freeze
  HIGHER_RANK_NAMES_ICN ||= NomenclaturalRank::Icn::HigherClassificationGroup.descendants.map(&:to_s).freeze
  HIGHER_RANK_NAMES_ICNP ||= NomenclaturalRank::Icnp::HigherClassificationGroup.descendants.map(&:to_s).freeze
  HIGHER_RANK_NAMES_ICVCN ||= ['NomenclaturalRank::Icvcn::Kingdom', 'NomenclaturalRank::Icvcn::Order'].freeze

  HIGHER_RANK_NAMES ||= (HIGHER_RANK_NAMES_ICZN + HIGHER_RANK_NAMES_ICN + HIGHER_RANK_NAMES_ICNP + HIGHER_RANK_NAMES_ICVCN).freeze

  # All assignable ranks for family group and above family names, for ICZN, ICN, ICNP
  FAMILY_AND_ABOVE_RANK_NAMES_ICZN ||= FAMILY_RANK_NAMES_ICZN + HIGHER_RANK_NAMES_ICZN
  FAMILY_AND_ABOVE_RANK_NAMES_ICN ||= FAMILY_RANK_NAMES_ICN + HIGHER_RANK_NAMES_ICN
  FAMILY_AND_ABOVE_RANK_NAMES_ICNP ||= FAMILY_RANK_NAMES_ICNP + HIGHER_RANK_NAMES_ICNP
  FAMILY_AND_ABOVE_RANK_NAMES_ICVCN ||= FAMILY_RANK_NAMES_ICVCN + HIGHER_RANK_NAMES_ICVCN

  # All assignable ranks for family group and above family names, for ICN, ICNP, and ICZN
  FAMILY_AND_ABOVE_RANK_NAMES ||= FAMILY_AND_ABOVE_RANK_NAMES_ICZN + FAMILY_AND_ABOVE_RANK_NAMES_ICN + FAMILY_AND_ABOVE_RANK_NAMES_ICNP + FAMILY_AND_ABOVE_RANK_NAMES_ICVCN

  # Assignable ranks for genus groups
  GENUS_RANK_NAMES_ICZN ||= NomenclaturalRank::Iczn::GenusGroup.descendants.map(&:to_s).freeze
  GENUS_RANK_NAMES_ICN ||= NomenclaturalRank::Icn::GenusGroup.descendants.map(&:to_s).freeze
  GENUS_RANK_NAMES_ICNP ||= NomenclaturalRank::Icnp::GenusGroup.descendants.map(&:to_s).freeze
  GENUS_RANK_NAMES_ICVCN ||= ['NomenclaturalRank::Icvcn::Genus'].freeze

  # All assignable ranks for genus groups, for ICN, ICNP, and ICZN
  GENUS_RANK_NAMES ||= ( GENUS_RANK_NAMES_ICZN + GENUS_RANK_NAMES_ICN + GENUS_RANK_NAMES_ICNP + GENUS_RANK_NAMES_ICVCN).freeze

  # Assignable ranks for species groups, for ICZN, ICN, ICNP
  SPECIES_RANK_NAMES_ICZN ||= NomenclaturalRank::Iczn::SpeciesGroup.descendants.map(&:to_s).freeze
  SPECIES_RANK_NAMES_ICN ||= NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.descendants.map(&:to_s).freeze
  SPECIES_RANK_NAMES_ICNP ||= NomenclaturalRank::Icnp::SpeciesGroup.descendants.map(&:to_s).freeze
  SPECIES_RANK_NAMES_ICVCN ||= ['NomenclaturalRank::Icvcn::Species'].freeze

  # All assignable ranks for species groups, for ICN, ICNP, and ICZN
  SPECIES_RANK_NAMES ||= ( SPECIES_RANK_NAMES_ICZN + SPECIES_RANK_NAMES_ICN + SPECIES_RANK_NAMES_ICNP + SPECIES_RANK_NAMES_ICVCN ).freeze

  # Assignable ranks for genus and species groups
  GENUS_AND_SPECIES_RANK_NAMES_ICZN ||= ( GENUS_RANK_NAMES_ICZN + SPECIES_RANK_NAMES_ICZN ).freeze
  GENUS_AND_SPECIES_RANK_NAMES_ICN ||= ( GENUS_RANK_NAMES_ICN + SPECIES_RANK_NAMES_ICN ).freeze
  GENUS_AND_SPECIES_RANK_NAMES_ICNP ||= ( GENUS_RANK_NAMES_ICNP + SPECIES_RANK_NAMES_ICNP ).freeze
  GENUS_AND_SPECIES_RANK_NAMES_ICVCN ||= ( GENUS_RANK_NAMES_ICVCN + SPECIES_RANK_NAMES_ICVCN ).freeze

  # Assignable ranks for genus and species groups, for ICN, ICNP, and ICZN
  GENUS_AND_SPECIES_RANK_NAMES ||= ( GENUS_RANK_NAMES + SPECIES_RANK_NAMES ).freeze

  # Assignable ranks for family, genus and species groups, for ICN, ICNP, and ICZN
  FAMILY_AND_GENUS_AND_SPECIES_RANK_NAMES ||= ( FAMILY_RANK_NAMES + GENUS_AND_SPECIES_RANK_NAMES ).freeze


  module RankHelper
    def self.rank_attributes(rank)
      rank.ordered_ranks.inject([]) {|ary, r|
        ary.push(
          {
            name: r.rank_name,
            rank_class: r.to_s,
            parent: r.parent_rank.rank_name,
            typical_use: r.typical_use
          }
        )
      }

    end
  end

  RANKS_JSON ||= {
    iczn: {
      higher: RankHelper::rank_attributes(NomenclaturalRank::Iczn::HigherClassificationGroup) ,
      family: RankHelper::rank_attributes(NomenclaturalRank::Iczn::FamilyGroup),
      genus: RankHelper::rank_attributes(NomenclaturalRank::Iczn::GenusGroup),
      species: RankHelper::rank_attributes(NomenclaturalRank::Iczn::SpeciesGroup)
    },
    icn:  {
      higher: RankHelper::rank_attributes(NomenclaturalRank::Icn::HigherClassificationGroup) ,
      family: RankHelper::rank_attributes(NomenclaturalRank::Icn::FamilyGroup),
      genus: RankHelper::rank_attributes(NomenclaturalRank::Icn::GenusGroup),
      species: RankHelper::rank_attributes(NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup)
    },
    icnp: {
      higher: RankHelper::rank_attributes(NomenclaturalRank::Icnp::HigherClassificationGroup) ,
      family: RankHelper::rank_attributes(NomenclaturalRank::Icnp::FamilyGroup),
      genus: RankHelper::rank_attributes(NomenclaturalRank::Icnp::GenusGroup),
      species: RankHelper::rank_attributes(NomenclaturalRank::Icnp::SpeciesGroup)
    },
    icvcn: {all: RankHelper::rank_attributes(NomenclaturalRank::Icvcn) }
  }.freeze

  # expected parent rank, check for validation purpose

  # TODO: make this concept pretty
  # See Protonymy#original_combination_elements for use in sorting
  ORIGINAL_COMBINATION_RANKS ||= %w{
  TaxonNameRelationship::OriginalCombination::OriginalGenus
  TaxonNameRelationship::OriginalCombination::OriginalSubgenus
  TaxonNameRelationship::OriginalCombination::OriginalSpecies
  TaxonNameRelationship::OriginalCombination::OriginalSubspecies
  TaxonNameRelationship::OriginalCombination::OriginalVariety
  TaxonNameRelationship::OriginalCombination::OriginalSubvariety
  TaxonNameRelationship::OriginalCombination::OriginalForm
  TaxonNameRelationship::OriginalCombination::OriginalSubform
  }.freeze

end
