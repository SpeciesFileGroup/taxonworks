class NomenclaturalRank::Icnb::HigherClassificationGroup::Subclass < NomenclaturalRank::Icnb::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Icnb::HigherClassificationGroup::ClassRank
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
  end

  def self.valid_parents
    [NomenclaturalRank::Icnb::HigherClassificationGroup::ClassRank.to_s]
  end
end
