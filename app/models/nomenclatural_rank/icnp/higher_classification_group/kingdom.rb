class NomenclaturalRank::Icnp::HigherClassificationGroup::Kingdom < NomenclaturalRank::Icnp::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Icnp
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, "Should be 'Archaea or Bacteria'") if taxon_name.name != 'Archaea' && taxon_name.name != 'Bacteria'

  end


end
