require 'application_enumeration'

# Contains methods used in /config/initializers/ranks.rb to generate Rank Classes 
module Ranks

  # In development the application must call .eager_load! for this code to work.  See /config/environment/development.rb.
  # TODO: check this now that Ranks moved to initializers.

  # Returns a NomenclaturalRank Class, the highest assignable for the rank Class passed.
  def self.top_rank(rank)
    all = rank.descendants 
    all.select!{|r| !r.parent_rank.nil?}
    all.each do |r| 
      return r if not all.include?(r.parent_rank)  
    end
  end

  # Returns an ordered Array of NomenclaturalRanks for all direct descendants of the provided base Class
  def self.ordered_ranks_for(rank)
    return false if rank == NomenclaturalRank || (rank.class.name =~ /NomenclaturalRank/)
    ordered = []
    top = Ranks.top_rank(rank)
    all = ApplicationEnumeration.all_submodels(rank)
    all.select!{|r| !r.parent_rank.nil?}
    ordered.push(top)
    return [] if all.size == 0
    # This sort algorithim is terrible, it could be optimized.
    while ordered.size != (all.size)
      all.each do |r|
        ordered.push(r) if (ordered.last == r.parent_rank)
      end
    end
    ordered
  end

  # Returns true if rank.to_s is the name of a NomenclaturalRank. 
  def self.valid?(rank)
    ::RANK_CLASS_NAMES.include?(rank.to_s)
  end
end

