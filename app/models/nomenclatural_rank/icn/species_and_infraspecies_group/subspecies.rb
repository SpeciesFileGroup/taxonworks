class NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Subspecies < NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup

  def self.parent_rank
    NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Species
  end

  def self.valid_parents
    [NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Species.to_s]
  end

  def self.abbreviation
    "subsp."
  end
end
