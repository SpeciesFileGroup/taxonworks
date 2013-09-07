# The base Class for all Nomenclature classes. 
# !! See /lib/Ranks for related Constants and Hooks
class NomenclaturalRank 

  # self.descendants gets all descendant classes
  # self.subclasses gets immediate descendants

  # These Constants must be accessed by their corresponding 
  # class method.
  
  # Should the rank be displayed in "typical" use?
  COMMON     = true

  # Return a String with the "common" name for this rank. 
  def self.rank_name
    n = self.name.demodulize.underscore.humanize.downcase
    if n == "nomenclatural rank"
      n = "root"
    end
    n
  end

  # The Class representing the immediate parent rank.  Required. 
  # Set to nil if a "root" level, this further implies that self
  # can not be assigned as a Rank to a TaxonName
  def self.parent_rank
    nil
  end

  def self.abbreviations
    []
  end
  
  def self.common?
    self::COMMON
  end

  # TODO: Think about this?
  # def year_of_applicability?
  #   nil
  # end

end
