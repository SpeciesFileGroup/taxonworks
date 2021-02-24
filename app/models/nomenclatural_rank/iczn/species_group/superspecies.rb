class NomenclaturalRank::Iczn::SpeciesGroup::Superspecies < NomenclaturalRank::Iczn::SpeciesGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::SpeciesGroup::Supersuperspecies
  end

  def self.typical_use
    true
  end

  def self.abbreviation
    'supersp.'
  end
end
