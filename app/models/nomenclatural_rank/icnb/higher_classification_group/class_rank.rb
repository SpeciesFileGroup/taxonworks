class NomenclaturalRank::Icnb::HigherClassificationGroup::ClassRank < NomenclaturalRank::Icnb::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Icnb::HigherClassificationGroup::Phylum
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
  end

  def rank_name
    'class'
  end

end
