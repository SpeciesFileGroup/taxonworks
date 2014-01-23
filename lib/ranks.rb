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

  def self.ordered_ranks_for_old(rank)
    return false if rank == NomenclaturalRank #|| (rank.class.name =~ /NomenclaturalRank/)
    ordered = []
    top = NomenclaturalRank.top_rank(rank)
    all = rank.descendants
    all.select!{|r| !r.parent_rank.nil?}
    ordered.push(top)
    return [] if all.size == 0

    # This sort algorithim is terrible, it could be optimized.
    ordered << all.detect { |r| ordered.last == r.parent_rank } while ordered.size != all.size
    
    return ordered
  end

  # Returns true if rank.to_s is the name of a NomenclaturalRank. 
  def self.valid?(rank)
     ::RANK_CLASS_NAMES.include?(rank.to_s) 
  end

  def self.lookup(code, rank)
    r = rank.downcase
    #if r == "class"
    #  r = "class rank"
    #end

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


