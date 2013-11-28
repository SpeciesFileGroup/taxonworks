class NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Variety < NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup

  def self.parent_rank
    NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Subspecies
  end

  def self.valid_parents
    [NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Species.to_s] + [NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Subspecies.to_s]
  end

  def self.abbreviation
    "var."
  end
end
