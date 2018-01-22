class NomenclaturalRank::Icnb::GenusGroup::Subgenus < NomenclaturalRank::Icnb::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Icnb::GenusGroup::Genus
  end

  def self.valid_parents
    [NomenclaturalRank::Icnb::GenusGroup::Genus.to_s]
  end

  def self.abbreviation
    'sgen.'
  end
end
