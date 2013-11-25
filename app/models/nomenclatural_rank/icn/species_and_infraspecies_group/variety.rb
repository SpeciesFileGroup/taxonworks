class NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Variety < NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup

  def self.parent_rank
    NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Subspecies
  end

  def self.abbreviation
    "var."
  end
end
