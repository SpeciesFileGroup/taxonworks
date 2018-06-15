class NomenclaturalRank::Icn::HigherClassificationGroup::Kingdom < NomenclaturalRank::Icn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Icn
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, "Should be 'Plantae or Fungi or Chromista'") if taxon_name.name != 'Plantae' && taxon_name.name != 'Fungi' && taxon_name.name != 'Chromista'
  end

end
