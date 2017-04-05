class NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Species < NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup

  def self.parent_rank
    NomenclaturalRank::Icn::GenusGroup::Subseries
  end

  def self.abbreviation
    "sp."
  end

end
