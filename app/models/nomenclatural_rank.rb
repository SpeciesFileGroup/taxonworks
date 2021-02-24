# A {NomenclaturalRank} is used to assert the (organizational) position of a
# taxon name within a nomenclatural hierarchy, according to the governed (or not) levels
# described in a corresponding nomenclatural code.
#
# See /lib/ranks.rb for related constants and hooks.
#
class NomenclaturalRank

  # self.descendants gets all descendant classes
  # self.subclasses gets immediate descendants


  # @return class
  #   this method calls Module#module_parent
  def self.parent
    self.module_parent
  end

  # @return [ordered Array of NomenclaturalRank]
  #   for all direct descendants of this Class.
  # Used to build constants in config/initializers/constants/ranks.rb.
  #
  # !! Further code should reference those constants rather than call this method.
  #
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

  # @return [NomenclaturalRank]
  #   the "top" rank for the nomenclatural group (e.g. ICZN species, genus, family) that this rank belongs to.
  def self.top_rank
    all = self.descendants
    all.select!{|r| !r.parent_rank.nil?}
    all.detect{|r| !all.include?(r.parent_rank)} # returns the first value found
  end

  # @return [NomenclaturalRank]
  #   the lowest assignable rank within the nomenclatural group (e.g. ICZN species, genus, family) that this class is part of
  def self.bottom_rank
    all = self.descendants
    all.select!{|r| !r.parent_rank.nil?}
    all_parents = all.collect{|i| i.parent_rank}
    all.detect{|r| !all_parents.include?(r)}
  end

  # @return [String]
  #   the "common" name for this rank
  def self.rank_name
    n = self.name.demodulize.underscore.humanize.downcase
    if n == 'potentially_validating rank'
      n = 'root'
    elsif n == 'class rank'
      n = 'class'
    end
    n
  end

  # @return [Symbol, nil]
  #   the name of the nomenclatural code, as a short symbol (:iczn, :icn), or nil
  def self.nomenclatural_code
    return :iczn if self.name.to_s =~ /Iczn/
    return :icnp if self.name.to_s =~ /Icnp/
    return :icvcn if self.name.to_s =~ /Icvcn/
    return :icn if self.name.to_s =~ /Icn/
    nil
  end

  # @return [NomenclaturalRank, nil]
  #   the parent class ({NomenclaturalRank::Iczn} or {NomenclaturalRank::Icn}) that this rank descends from
  def self.nomenclatural_code_class
    case self.nomenclatural_code
    when :iczn
      NomenclaturalRank::Iczn
    when :icnp
      NomenclaturalRank::Icnp
    when :icvcn
      NomenclaturalRank::Icvcn
    when :icn
      NomenclaturalRank::Icn
    else
      nil
    end
  end

  # The following attributes are stubbed here and over-ridden in subclasses.

  # @return [Boolean]
  #   should the rank be displayed in "typical" use?
  def self.typical_use
    true
  end

  # @return [NomenclaturalRank, nil]
  #   the immediate parent {NomenclaturalRank} of this class, nil if a "root" level (e.g. {NomenclaturalRank::Iczn}, {NomenclaturalRank::Icn})
  #
  # All subclasses must override this method.
  # nil returning classes can not be assigned as a {NomenclaturalRank} to a {TaxonName}!
  def self.parent_rank
    nil
  end

  # @return [String, nil]
  #   a TW preferred abbreviated name for this rank, e.g. "fam."
  def self.abbreviation
    nil
  end

  # @return [Array of NomenclaturalRank]
  #   the TaxonName assignable {NomenclaturalRank}s that this rank descend from
  def self.valid_parents
    []
  end

  def self.valid_name_ending
    ''
  end

  # TODO: move this to string method
  def self.collect_to_s(*args)
    args.collect{|arg| arg.to_s}
  end

  # TODO: move this to lib/application_ennumeration
  # !! The use of this moved into a frozen or || solution likely.
  def self.collect_descendants_to_s(*classes)
    ans = []
    classes.each do |klass|
      ans += klass.descendants.collect{|k| k.to_s}
    end
    ans
  end

end

Dir[Rails.root.to_s + '/app/models/nomenclatural_rank/**/*.rb'].each { |file| require_dependency file }
