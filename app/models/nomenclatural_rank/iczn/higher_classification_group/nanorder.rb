class NomenclaturalRank::Iczn::HigherClassificationGroup::Nanorder < NomenclaturalRank::Iczn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::HigherClassificationGroup::Parvorder
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
  end

  def self.typical_use
    false
  end

end
