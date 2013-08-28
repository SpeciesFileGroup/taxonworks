# Be sure to restart your server when you modify this file.

 # ICN Rank Classes ordered in an Array
 ICN = Ranks.ordered_ranks_for(NomenclaturalRank::Icn)
 
 # ICZN Rank Classes ordered in an Array
 ICZN = Ranks.ordered_ranks_for(NomenclaturalRank::Iczn)

 # All assignable Rank Classes
 RANKS = ICN + ICZN

 # All Ranks, as Strings
 RANK_CLASS_NAMES = RANKS.collect{|r| r.to_s}

 # ICN Rank Classes in a Hash with keys being the "human" name
 # For example, to return the class for a plant family:
 #   Ranks::ICN_LOOKUP['family']
 ICN_LOOKUP = ICN.inject({}){|hsh, r| hsh.merge!(r.rank_name => r)}
 
 # ICZN Rank Classes in a Hash with keys being the "human" name
 ICZN_LOOKUP = ICZN.inject({}){|hsh, r| hsh.merge!(r.rank_name => r)}

