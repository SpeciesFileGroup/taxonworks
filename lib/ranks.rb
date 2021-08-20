require_dependency 'application_enumeration'

# Contains methods used in /config/initializers/constants/ranks.rb to generate Rank Classes
module Ranks

  # Duplicated somewhere?
  CODES = [:iczn, :icn, :icnp, :icvcn].freeze

  # @return [Boolean] true if rank.to_s is the name of a NomenclaturalRank.
  # @param [String] rank
  def self.valid?(rank)
    ::RANKS.include?(rank.to_s)
  end

  # @param code [Symbol]
  # @param rank [Symbol] 
  # @return [String] representing the name of the NomenclaturalRank class
  #   Ranks::lookup(:iczn, 'superfamily')   # => 'NomenclaturalRank::Iczn::FamilyGroup::Superfamily'
  def self.lookup(code, rank)
    rank = rank.to_s
    raise "code '#{code}' is not a valid code" if !Ranks::CODES.include?(code)
    r = rank.downcase
    case code
      when :iczn
        ::ICZN_LOOKUP[r]
      when :icnp
        ::ICNP_LOOKUP[r]
      when :icvcn
        ::ICVCN_LOOKUP[r]
      when :icn
        ::ICN_LOOKUP[r]
      else
        return false
    end
  end

end
