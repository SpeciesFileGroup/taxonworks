class NomenclaturalRank::Icnp::GenusGroup::Genus < NomenclaturalRank::Icnp::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Icnp::FamilyGroup::Subtribe
  end

  def self.abbreviation
    'gen.'
  end
end
