class NomenclaturalRank::Iczn::HigherClassificationGroup::Nanorder < NomenclaturalRank::Iczn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::HigherClassificationGroup::Parvorder
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2

    # @todo: @mjy: superfamily group rank in SF does not have type genus nor any naming constraints. Following line was commented out for temporary import compatibility.
    # taxon_name.errors.add(:name, 'name must end in -oidea') if not(taxon_name.name =~ /.*oidea\Z/)

  end

  def self.typical_use
    false
  end

end
