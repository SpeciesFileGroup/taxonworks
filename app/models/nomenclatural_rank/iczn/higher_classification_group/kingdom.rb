class NomenclaturalRank::Iczn::HigherClassificationGroup::Kingdom < NomenclaturalRank::Iczn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::HigherClassificationGroup::Superkingdom
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, "Should be one of #{NomenclaturalRank::Iczn::KINGDOM.to_sentence}") if !NomenclaturalRank::Iczn::KINGDOM.include?(taxon_name.name)
  end

end
