# require 'application_enumeration'

# Contains methods used in /config/initializers/constants/ranks.rb to generate Rank Classes
module Ranks

  # Returns true if rank.to_s is the name of a NomenclaturalRank. 
  def self.valid?(rank)
     ::RANKS.include?(rank.to_s) 
  end

  # Returns a String representing the name of the NomenclaturalRank class
  #   Ranks::lookup(:iczn, 'superfamily')   # => 'NomenclaturalRank::Iczn::FamilyGroup::Superfamily'
  def self.lookup(code, rank)
    rank = rank.to_s
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


