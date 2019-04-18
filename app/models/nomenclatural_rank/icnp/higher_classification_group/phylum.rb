class NomenclaturalRank::Icnp::HigherClassificationGroup::Phylum < NomenclaturalRank::Icnp::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Icnp::HigherClassificationGroup::Kingdom
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
  end
end
