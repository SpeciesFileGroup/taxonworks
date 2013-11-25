class NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Subvariety < NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup

  def self.parent_rank
    NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Variety
  end

  def self.valid_parents
    NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Variety
  end

  def self.abbreviation
    "subvar."
  end
end
