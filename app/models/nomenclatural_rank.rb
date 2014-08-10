# A NomenclaturalRank is used to assert the (origanizationl) position of a 
# taxon name within a nomenclatural hierarchy, according to the governed (or not) levels 
# described in a corresponding nomenclatural code.
# 
# !! See /lib/Ranks for related Constants and hooks
#
class NomenclaturalRank

  # self.descendants gets all descendant classes
  # self.subclasses gets immediate descendants

  # These attributes must be accessed by their corresponding 
  # class method.

  # Should the rank be displayed in "typical" use?
  def self.typical_use
    true
  end

  # Returns an ordered Array of NomenclaturalRanks for all direct descendants of this Class. 
  # Used to build constants in config/initializers/constants/ranks.rb.  Further code should reference
  # those constant rather than call this method. 
  def self.ordered_ranks 
    return false if self.name == 'NomenclaturalRank' # || (rank.class.name =~ /NomenclaturalRank/)
    ordered = []
    bottom = bottom_rank 
    top = top_rank 
    ordered.push(bottom)
    ordered << ordered.last.parent_rank while ordered.last != top
    ordered.reverse!
    return ordered
  end

  # Returns a NomenclaturalRank Class, the "top" for the group the rank belongs to.  See specs.
  def self.top_rank 
    all = self.descendants
    all.select!{|r| !r.parent_rank.nil?}
    all.detect{|r| !all.include?(r.parent_rank)} # returns the first value found
  end

  # Returns a NomenclaturalRank Class, the lowest assignable for the rank Class passed.
  def self.bottom_rank
    all = self.descendants
    all.select!{|r| !r.parent_rank.nil?}
    all_parents = all.collect{|i| i.parent_rank}
    all.detect{|r| !all_parents.include?(r)}
  end

  # Return a String with the "common" name for this rank. 
  def self.rank_name
    n = self.name.demodulize.underscore.humanize.downcase
    if n == 'potentially_validating rank'
      n = 'root'
    elsif n == 'class rank'
      n = 'class'
    end
    n
  end

  # Returns a potentially_validating code name for this taxon
  def self.nomenclatural_code
    return :iczn if self.name.to_s =~ /Iczn/
    return :icn if self.name.to_s =~ /Icn/
    return nil 
  end

  # returns a potentially_validating code class for this taxon
  def self.nomenclatural_code_class
    case self.nomenclatural_code
    when :iczn
      NomenclaturalRank::Iczn
    when :icn
      NomenclaturalRank::Icn
    else
      nil
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

  def self.valid_parents
    []
  end
  
  private

  def self.collect_to_s(*args)
    args.collect{|arg| arg.to_s}
  end

  def self.collect_descendants_to_s(*classes)
    ans = []
    classes.each do |klass|
      ans += klass.descendants.collect{|k| k.to_s}
    end
    ans    
  end

end

