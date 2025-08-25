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
  #   the name of the nomenclatural code, as a short symbol (:iczn, :icn, etc.), or nil
  def self.nomenclatural_code

    return :iczn if self.name.to_s =~ /Iczn/
    return :icnp if self.name.to_s =~ /Icnp/
    return :icvcn if self.name.to_s =~ /Icvcn/
    return :icn if self.name.to_s =~ /Icn/ # order matters
    nil
  end

  # TODO: unused
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

  # @param ranks Array
  #   of  rank classes as string ( [ "NomenclaturalRank::Iczn::HigherClassificationGroup::Infraclass", ...] )
  def self.order_ranks(rank_classes)
    rank_classes.sort{|a,b| RANKS.index(a) <=> RANKS.index(b)}
  end

  # @param: expand
  #   true - include all columns discovered
  # @params ranks Array
  #   always include these ranks, regardless of whether they are present in the scope
  def self.rank_expansion_sql(ranks: [], expand: false, scope: nil, nomenclatural_code: nil, gender: true)

    # Get the classes for the ranks supplied
    rank_classes = ranks.collect{|a| Ranks.lookup(:iczn, a)}

    # Expand them to the observed ranks within the scope
    rank_classes += scope.select(:rank_class).distinct.pluck(:rank_class) if expand
    rank_classes.uniq!
    ranks = NomenclaturalRank.order_ranks( rank_classes )

    rank_names = ranks.collect{|a| a.safe_constantize.rank_name}.uniq
    rank_names.delete('nomenclatural rank')

    # TODO: EXPAND TO INCLUDE GENDER VALUE HERE { if ranks includes genera }

   s = rank_names.collect{|n|
      "MAX(CASE WHEN parent.rank_class LIKE \'%::#{n.capitalize}\' THEN parent.name END) AS #{n}"
    }.join(",\n")

    if gender
      g = rank_names.select{|n| n =~ /[Gg]enus/}.collect{|m|
        "MAX(CASE WHEN parent.rank_class LIKE \'%::#{m.capitalize}\' THEN parent.cached_gender END) AS #{m}_gender"
      }.join(",\n")
    end

    s = s + ', ' + g if !g.blank?
    s
  end

  private

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

end

# TODO: still required for config of RANK related constants, should be removable
Dir[Rails.root.to_s + '/app/models/nomenclatural_rank/**/*.rb'].each { |file| require_dependency file }
