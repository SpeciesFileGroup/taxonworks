# The base Class for all Nomenclature classes. The class of a TaxonName root. 
# !! See /lib/Ranks for related Constants and Hooks
class NomenclaturalRank 

  # self.descendants gets all descendant classes
  # self.subclasses gets immediate descendants

  # These Constants must be accessed by their corresponding 
  # class method.

  # TODO: refactor/clarify 
  # Should the rank be displayed in "typical" use?
  COMMON     = true

  def self.top_rank(rank)
    all = rank.descendants
    all.detect { |r| !(r.parent_rank.nil? or all.include?(r.parent_rank)) }
  end

  # Return a String with the "common" name for this rank. 
  def self.rank_name
    n = self.name.demodulize.underscore.humanize.downcase
    if n == "nomenclatural rank"
      n = "root"
    elsif n == "classrank"
      n = "class"
    end
    n
  end

  # returns a nomenclatural code name for this taxon
  def self.nomenclatural_code
    if ::ICZN.include?(self)
      return :iczn
    elsif ::ICN.include?(self)
      return :icn
    else
      return nil
    end
  end

  # returns a nomenclatural code class for this taxon
  def self.nomenclatural_code_class
    if ::ICZN.include?(self)
      return NomenclaturalRank::Iczn
    elsif ::ICN.include?(self)
      return NomenclaturalRank::Icn
    else
      return nil
    end
  end

  # The Class representing the immediate parent rank.  Required. 
  # Set to nil if a "root" level, this further implies that self
  # can not be assigned as a Rank to a TaxonName
  def self.parent_rank
    nil
  end

  def self.abbreviation
    nil
  end

  def self.available_parents
    NomenclaturalRank
  end

  def self.common?
    self::COMMON
  end

  # TODO: Think about this?
  # def year_of_applicability?
  #   nil
  # end

end
