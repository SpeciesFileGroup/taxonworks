class NomenclaturalRank::Icn::GenusGroup::Section < NomenclaturalRank::Icn::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Icn::GenusGroup::Subgenus
  end

  def self.valid_parents
    [NomenclaturalRank::Icn::GenusGroup::Genus.to_s] + [NomenclaturalRank::Icn::GenusGroup::Subgenus.to_s]
  end

  def self.abbreviation
    "sect."
  end
end
