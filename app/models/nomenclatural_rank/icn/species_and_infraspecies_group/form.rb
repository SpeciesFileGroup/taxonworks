class NomenclaturalRank::Icn::SpeciesGroup::Form < NomenclaturalRank::Icn::SpeciesGroup

  def self.parent_rank
    NomenclaturalRank::Icn::SpeciesGroup::Subvariety
  end

  def self.valid_parents
    [NomenclaturalRank::Icn::SpeciesGroup::Species.to_s] + [NomenclaturalRank::Icn::SpeciesGroup::Subspecies.to_s] + [NomenclaturalRank::Icn::SpeciesGroup::Variety.to_s] + [NomenclaturalRank::Icn::SpeciesGroup::Subvariety.to_s]
  end


  def self.abbreviation
    "f."
  end
end
