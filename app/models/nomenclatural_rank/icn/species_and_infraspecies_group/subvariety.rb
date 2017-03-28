class NomenclaturalRank::Icn::SpeciesGroup::Subvariety < NomenclaturalRank::Icn::SpeciesGroup

  def self.parent_rank
    NomenclaturalRank::Icn::SpeciesGroup::Variety
  end

  def self.valid_parents
    [NomenclaturalRank::Icn::SpeciesGroup::Variety.to_s]
  end

  def self.abbreviation
    "subvar."
  end
end
