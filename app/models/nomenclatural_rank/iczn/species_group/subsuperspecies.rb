class NomenclaturalRank::Iczn::SpeciesGroup::Subsuperspecies < NomenclaturalRank::Iczn::SpeciesGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::SpeciesGroup::Superspecies
  end

  def self.typical_use
    false
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::SpeciesGroup::Superspecies.to_s]
  end

  def self.abbreviation
    'subsupersp.'
  end
end
