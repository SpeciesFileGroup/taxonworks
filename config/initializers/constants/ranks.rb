# Be sure to restart your server when you modify this file.

# !! All constants are now composed of Strings only.  They must not reference a class. !!

# ICN class names ordered in an Array
ICN = NomenclaturalRank::Icn.ordered_ranks.collect{|r| r.to_s}.freeze

# ICZN class names  ordered in an Array
ICZN = NomenclaturalRank::Iczn.ordered_ranks.collect{|r| r.to_s}.freeze

# ICNB class names  ordered in an Array
ICNB = NomenclaturalRank::Icnb.ordered_ranks.collect{|r| r.to_s}.freeze

# All assignable Rank Classes 
RANKS = ( ['NomenclaturalRank'] + ICN + ICZN + ICNB).freeze

# ICN Rank Classes in a Hash with keys being the "human" name
# For example, to return the class for a plant family:
#   ::ICN_LOOKUP['family']
ICN_LOOKUP = ICN.inject({}){|hsh, r| hsh.merge!(r.constantize.rank_name => r)}.freeze

#   ::ICNB_LOOKUP['family']
ICNB_LOOKUP = ICNB.inject({}){|hsh, r| hsh.merge!(r.constantize.rank_name => r)}.freeze

# ICZN Rank Classes in a Hash with keys being the "human" name
ICZN_LOOKUP = ICZN.inject({}){|hsh, r| hsh.merge!(r.constantize.rank_name => r)}.freeze

# All ranks, with keys as class strings pointing to common usage
RANKS_LOOKUP = ICN_LOOKUP.invert.merge(ICZN_LOOKUP.invert.merge(ICNB_LOOKUP.invert)).freeze

# An Array of Arrays, used in options for select
#   [["class (ICN)", "NomenclaturalRank::Icn::HigherClassificationGroup::ClassRank"] .. ]
RANKS_SELECT_OPTIONS = RANKS_LOOKUP.collect{|k,v| ["#{v} " + ((k.to_s =~ /Iczn/) ? '(ICZN)' : ((k.to_s =~ /Icnb/) ? '(ICNB)' : '(ICN)') ), k, {class: ((k.to_s =~ /Iczn/) ? :iczn : ((k.to_s =~ /Icnb/) ? :icnb : :icn)) }] }.sort{|a, b| a[0] <=> b[0]}.freeze

# All assignable ranks for family groups, for ICZN
FAMILY_RANK_NAMES_ICZN = NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|i| i.to_s}.freeze

# All assignable ranks for family groups, for ICN
FAMILY_RANK_NAMES_ICN = NomenclaturalRank::Icn::FamilyGroup.descendants.collect{|i| i.to_s}.freeze

# All assignable ranks for family groups, for ICNB
FAMILY_RANK_NAMES_ICNB = NomenclaturalRank::Icnb::FamilyGroup.descendants.collect{|i| i.to_s}.freeze

# All assignable ranks for family group, for ICN, ICNB, and ICZN
FAMILY_RANK_NAMES =  ( FAMILY_RANK_NAMES_ICZN + FAMILY_RANK_NAMES_ICN + FAMILY_RANK_NAMES_ICNB ).freeze

# All assignable ranks for family group and above family names, for ICZN
FAMILY_AND_ABOVE_RANK_NAMES_ICZN = FAMILY_RANK_NAMES_ICZN +
  (NomenclaturalRank::Iczn::HigherClassificationGroup.descendants).collect{|i| i.to_s}.freeze

# All assignable ranks for family group and above family names, for ICN, ICNB, and ICZN
FAMILY_AND_ABOVE_RANK_NAMES = FAMILY_AND_ABOVE_RANK_NAMES_ICZN +
  (NomenclaturalRank::Icn::HigherClassificationGroup.descendants +
   NomenclaturalRank::Icn::FamilyGroup.descendants).collect{|i| i.to_s} +
   (NomenclaturalRank::Icnb::HigherClassificationGroup.descendants +
   NomenclaturalRank::Icnb::FamilyGroup.descendants).collect{|i| i.to_s}.freeze

# All assignable ranks for genus groups, for ICZN
GENUS_RANK_NAMES_ICZN = NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|i| i.to_s}.freeze

# All assignable ranks for genus groups, for both ICN
GENUS_RANK_NAMES_ICN = NomenclaturalRank::Icn::GenusGroup.descendants.collect{|i| i.to_s}.freeze

# All assignable ranks for genus groups, for both ICNB
GENUS_RANK_NAMES_ICNB = NomenclaturalRank::Icnb::GenusGroup.descendants.collect{|i| i.to_s}.freeze

# All assignable ranks for species groups, for ICZN
SPECIES_RANK_NAMES_ICZN = NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|i| i.to_s}.freeze

# All assignable ranks for species groups, for both ICN
SPECIES_RANK_NAMES_ICN = NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.descendants.collect{|i| i.to_s}.freeze

# All assignable ranks for species groups, for both ICNB
SPECIES_RANK_NAMES_ICNB = NomenclaturalRank::Icnb::SpeciesGroup.descendants.collect{|i| i.to_s}.freeze

# All assignable ranks for genus and species groups, for both ICZN
GENUS_AND_SPECIES_RANK_NAMES_ICZN = ( GENUS_RANK_NAMES_ICZN + SPECIES_RANK_NAMES_ICZN ).freeze

# All assignable ranks for genus and species groups, for both ICN
GENUS_AND_SPECIES_RANK_NAMES_ICN = ( GENUS_RANK_NAMES_ICN + SPECIES_RANK_NAMES_ICN ).freeze

# All assignable ranks for genus and species groups, for both ICNB
GENUS_AND_SPECIES_RANK_NAMES_ICNB = ( GENUS_RANK_NAMES_ICNB + SPECIES_RANK_NAMES_ICNB ).freeze

# All assignable ranks for genus groups, for ICN, ICNB, and ICZN
GENUS_RANK_NAMES = ( GENUS_RANK_NAMES_ICZN + GENUS_RANK_NAMES_ICN + GENUS_RANK_NAMES_ICNB ).freeze

# All assignable ranks for species groups, for ICN, ICNB, and ICZN
SPECIES_RANK_NAMES = ( SPECIES_RANK_NAMES_ICZN + SPECIES_RANK_NAMES_ICN + SPECIES_RANK_NAMES_ICNB ).freeze

# All assignable ranks for genus and species groups, for ICN, ICNB, and ICZN
GENUS_AND_SPECIES_RANK_NAMES = ( GENUS_RANK_NAMES + SPECIES_RANK_NAMES ).freeze


