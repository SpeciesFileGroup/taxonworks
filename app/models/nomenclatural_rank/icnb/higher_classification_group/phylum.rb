class NomenclaturalRank::Icnb::HigherClassificationGroup::Phylum < NomenclaturalRank::Icnb::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Icnb::HigherClassificationGroup::Kingdom
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
  end
end
