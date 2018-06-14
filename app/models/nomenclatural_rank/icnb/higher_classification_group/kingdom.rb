class NomenclaturalRank::Icnb::HigherClassificationGroup::Kingdom < NomenclaturalRank::Icnb::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Icnb
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, "Should be 'Bacteria or Archaea'") if taxon_name.name != 'Bacteria' && taxon_name.name != 'Archaea'
  end


end
