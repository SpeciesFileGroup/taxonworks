# Be sure to restart your server when you modify this file.

 # ICN Rank Classes ordered in an Array
 ICN = Ranks.ordered_ranks_for(NomenclaturalRank::Icn)
 
 # ICZN Rank Classes ordered in an Array
 ICZN = Ranks.ordered_ranks_for(NomenclaturalRank::Iczn)

 # All assignable Rank Classes
 RANKS = [NomenclaturalRank] + ICN + ICZN

 # All Ranks, as Strings
 # TODO: Is there a point to this?
 RANK_CLASS_NAMES = RANKS.collect{|r| r.to_s}

 # ICN Rank Classes in a Hash with keys being the "human" name
 # For example, to return the class for a plant family:
 #   ::ICN_LOOKUP['family']
 ICN_LOOKUP = ICN.inject({}){|hsh, r| hsh.merge!(r.rank_name => r)}
 
 # ICZN Rank Classes in a Hash with keys being the "human" name
 ICZN_LOOKUP = ICZN.inject({}){|hsh, r| hsh.merge!(r.rank_name => r)}

# All assignable ranks for family group and above family names, for both ICN and ICZN
FAMILY_AND_ABOVE_RANKS_NAMES = (NomenclaturalRank::Iczn::AboveFamilyGroup.descendants +
      NomenclaturalRank::Iczn::FamilyGroup.descendants +
      NomenclaturalRank::Icn::AboveFamilyGroup.descendants +
      NomenclaturalRank::Icn::FamilyGroup.descendants).collect{|i| i.to_s}

# All assignable ranks for family group, for both ICN and ICZN
FAMILY_RANKS_NAMES = (NomenclaturalRank::Iczn::FamilyGroup.descendants +
    NomenclaturalRank::Icn::FamilyGroup.descendants).collect{|i| i.to_s}

# All assignable ranks for genus groups, for both ICN and ICZN
GENUS_RANKS_NAMES = (NomenclaturalRank::Iczn::GenusGroup.descendants +
    NomenclaturalRank::Icn::GenusGroup.descendants).collect{|i| i.to_s}

# All assignable ranks for genus and species groups, for both ICN and ICZN
GENUS_AND_SPECIES_RANKS_NAMES = (NomenclaturalRank::Iczn::GenusGroup.descendants +
      NomenclaturalRank::Iczn::SpeciesGroup.descendants +
      NomenclaturalRank::Icn::GenusGroup.descendants +
      NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.descendants).collect{|i| i.to_s}

# All assignable ranks for species groups, for both ICN and ICZN
SPECIES_RANKS_NAMES = (NomenclaturalRank::Iczn::SpeciesGroup.descendants +
    NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.descendants).collect{|i| i.to_s}
