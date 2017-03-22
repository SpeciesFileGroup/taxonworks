class NomenclaturalRank::Icn::SpeciesGroup::Species < NomenclaturalRank::Icn::SpeciesGroup

  def self.parent_rank
    NomenclaturalRank::Icn::GenusGroup::Subseries
  end

  def self.abbreviation
    "sp."
  end

end
