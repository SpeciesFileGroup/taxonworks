require 'application_enumeration'

# Contains methods used in /config/initializers/ranks.rb to generate Rank Classes 
module Ranks

  # In development the application must call .eager_load! for this code to work.  See /config/environment/development.rb.
  # TODO: check this now that Ranks moved to initializers.

  # Returns an ordered Array of NomenclaturalRanks for all direct descendants of the provided base Class
  def self.ordered_ranks_for(rank)
    return false if rank == NomenclaturalRank #|| (rank.class.name =~ /NomenclaturalRank/)
    ordered = []
    bottom = NomenclaturalRank.bottom_rank(rank)
    top = NomenclaturalRank.top_rank(rank)
    ordered.push(bottom)
    ordered << ordered.last.parent_rank while ordered.last != top
    ordered.reverse!
    return ordered
  end

  # Returns true if rank.to_s is the name of a NomenclaturalRank. 
  def self.valid?(rank)
     ::RANKS.include?(rank.to_s) 
  end

  # Returns a String representing the name of the NomenclaturalRank class
  #   Ranks::lookup(:iczn, 'superfamily')   # => 'NomenclaturalRank::Iczn::FamilyGroup::Superfamily'
  def self.lookup(code, rank)
    raise if ![:iczn, :icn].include?(code)
    r = rank.downcase
    case code
      when :iczn
        ::ICZN_LOOKUP[r]
      when :icn
        ::ICN_LOOKUP[r]
      else
        return false
    end
  end
end


