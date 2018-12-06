class NomenclaturalRank::Icnp::SpeciesGroup::Subspecies < NomenclaturalRank::Icnp::SpeciesGroup

  def self.parent_rank
    NomenclaturalRank::Icnp::SpeciesGroup::Species
  end

  def self.valid_parents
    [NomenclaturalRank::Icnp::SpeciesGroup::Species.to_s]
  end

  def self.abbreviation
    'subsp.'
  end
end
