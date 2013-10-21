require 'application_enumeration'


# Contains methods used in /config/initializers/ranks.rb to generate Rank Classes 
module Ranks

  # In development the application must call .eager_load! for this code to work.  See /config/environment/development.rb.
  # TODO: check this now that Ranks moved to initializers.

  # Returns a NomenclaturalRank Class, the highest assignable for the rank Class passed.
  def self.top_rank(rank)
    all = rank.descendants
    all.detect { |r| !(r.parent_rank.nil? or all.include?(r.parent_rank)) }
  end

  # Returns an ordered Array of NomenclaturalRanks for all direct descendants of the provided base Class
  def self.ordered_ranks_for(rank)
    return false if rank == NomenclaturalRank || (rank.class.name =~ /NomenclaturalRank/)
    ordered = []
    top = Ranks.top_rank(rank)
    all = rank.descendants # ApplicationEnumeration.all_submodels(rank)
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


