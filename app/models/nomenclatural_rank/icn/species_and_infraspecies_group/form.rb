class NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Form < NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup

  def self.parent_rank
    NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Subvariety
  end

  def self.valid_parents
    [NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Species.to_s] + [NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Subspecies.to_s] + [NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Variety.to_s] + [NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Subvariety.to_s]
  end


  def self.abbreviation
    "f."
  end
end
