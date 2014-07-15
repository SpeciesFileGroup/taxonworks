# The base Class for all Nomenclature classes. The class of a TaxonName root. 
# !! See /lib/Ranks for related Constants and Hooks
class NomenclaturalRank

  # self.descendants gets all descendant classes
  # self.subclasses gets immediate descendants

  # These Constants must be accessed by their corresponding 
  # class method.

  # Should the rank be displayed in "typical" use?
  def self.typical_use
    true
  end

  # Returns a NomenclaturalRank Class, the highest assignable for the rank Class passed.
  def self.top_rank(rank)
    all = rank.descendants
    all.select!{|r| !r.parent_rank.nil?}
    all.detect{|r| !all.include?(r.parent_rank)}
#    all.detect { |r| !(r.parent_rank.nil? or all.include?(r.parent_rank)) }
  end

  # Returns a NomenclaturalRank Class, the lowest assignable for the rank Class passed.
  def self.bottom_rank(rank)
    all = rank.descendants
    all.select!{|r| !r.parent_rank.nil?}
    all_parents = all.collect{|i| i.parent_rank}
    all.detect{|r| !all_parents.include?(r)}
#    all.detect { |r| !(r.parent_rank.nil? or all_parents.include?(r)) }
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

  # returns a potentially_validating code name for this taxon
  def self.nomenclatural_code
    if ::RANK_CLASS_NAMES_ICZN.include?(self.to_s)
      return :iczn
    elsif ::RANK_CLASS_NAMES_ICN.include?(self.to_s)
      return :icn
    else
      return nil
    end
  end

  # returns a potentially_validating code class for this taxon
  def self.nomenclatural_code_class
    if ::RANK_CLASS_NAMES_ICZN.include?(self.to_s)
      return NomenclaturalRank::Iczn
    elsif ::RANK_CLASS_NAMES_ICN.include?(self.to_s)
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
