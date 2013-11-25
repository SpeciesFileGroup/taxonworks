class NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Subform < NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup

  def self.parent_rank
    NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Form
  end

  def self.valid_parents
    NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Form
  end

  def self.abbreviation
    "subf."
  end
end
