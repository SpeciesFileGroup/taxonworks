class NomenclaturalRank::Icn::HigherClassificationGroup::Kingdom < NomenclaturalRank::Icn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Icn
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, "Should be one of #{NomenclaturalRank::Icn::KINGDOM.to_sentence}") if !NomenclaturalRank::Icn::KINGDOM.include?(taxon_name.name)
  end

end
