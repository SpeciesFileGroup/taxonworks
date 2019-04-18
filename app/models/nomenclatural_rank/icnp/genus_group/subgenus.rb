class NomenclaturalRank::Icnp::GenusGroup::Subgenus < NomenclaturalRank::Icnp::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Icnp::GenusGroup::Genus
  end

  def self.valid_parents
    [NomenclaturalRank::Icnp::GenusGroup::Genus.to_s]
  end

  def self.abbreviation
    'sgen.'
  end
end
