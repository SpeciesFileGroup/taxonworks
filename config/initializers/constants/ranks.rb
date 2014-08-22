# Be sure to restart your server when you modify this file.

# !! All constants are now composed of Strings only.  They must not reference a class. !!

# ICN class names ordered in an Array
ICN = NomenclaturalRank::Icn.ordered_ranks.collect{|r| r.to_s}

# ICZN class names  ordered in an Array
ICZN = NomenclaturalRank::Iczn.ordered_ranks.collect{|r| r.to_s}

# All assignable Rank Classes 
RANKS = ['NomenclaturalRank'] + ICN + ICZN

# ICN Rank Classes in a Hash with keys being the "human" name
# For example, to return the class for a plant family:
#   ::ICN_LOOKUP['family']
ICN_LOOKUP = ICN.inject({}){|hsh, r| hsh.merge!(r.constantize.rank_name => r)}

# ICZN Rank Classes in a Hash with keys being the "human" name
ICZN_LOOKUP = ICZN.inject({}){|hsh, r| hsh.merge!(r.constantize.rank_name => r)}

# All assignable ranks for family groups, for ICZN
FAMILY_RANK_NAMES_ICZN = NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|i| i.to_s}

# All assignable ranks for family groups, for ICN
FAMILY_RANK_NAMES_ICN = NomenclaturalRank::Icn::FamilyGroup.descendants.collect{|i| i.to_s}

# All assignable ranks for family group, for both ICN and ICZN
FAMILY_RANK_NAMES = FAMILY_RANK_NAMES_ICZN + FAMILY_RANK_NAMES_ICN

# All assignable ranks for family group and above family names, for ICZN
FAMILY_AND_ABOVE_RANK_NAMES_ICZN = FAMILY_RANK_NAMES_ICZN +
    (NomenclaturalRank::Iczn::HigherClassificationGroup.descendants).collect{|i| i.to_s}

# All assignable ranks for family group and above family names, for both ICN and ICZN
FAMILY_AND_ABOVE_RANK_NAMES = FAMILY_AND_ABOVE_RANK_NAMES_ICZN +
    (NomenclaturalRank::Icn::HigherClassificationGroup.descendants +
    NomenclaturalRank::Icn::FamilyGroup.descendants).collect{|i| i.to_s}

# All assignable ranks for genus groups, for ICZN
GENUS_RANK_NAMES_ICZN = NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|i| i.to_s}

# All assignable ranks for genus groups, for both ICN
GENUS_RANK_NAMES_ICN = NomenclaturalRank::Icn::GenusGroup.descendants.collect{|i| i.to_s}

# All assignable ranks for species groups, for ICZN
SPECIES_RANK_NAMES_ICZN = NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|i| i.to_s}

# All assignable ranks for species groups, for both ICN
SPECIES_RANK_NAMES_ICN = NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.descendants.collect{|i| i.to_s}

# All assignable ranks for genus and species groups, for both ICZN
GENUS_AND_SPECIES_RANK_NAMES_ICZN = GENUS_RANK_NAMES_ICZN + SPECIES_RANK_NAMES_ICZN

# All assignable ranks for genus and species groups, for both ICN
GENUS_AND_SPECIES_RANK_NAMES_ICN = GENUS_RANK_NAMES_ICN + SPECIES_RANK_NAMES_ICN

# All assignable ranks for genus groups, for both ICN and ICZN
GENUS_RANK_NAMES = GENUS_RANK_NAMES_ICZN + GENUS_RANK_NAMES_ICN

# All assignable ranks for species groups, for both ICN and ICZN
SPECIES_RANK_NAMES = SPECIES_RANK_NAMES_ICZN + SPECIES_RANK_NAMES_ICN

# All assignable ranks for genus and species groups, for both ICN and ICZN
GENUS_AND_SPECIES_RANK_NAMES = GENUS_RANK_NAMES + SPECIES_RANK_NAMES


