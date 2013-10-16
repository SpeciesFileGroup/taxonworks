class NomenclaturalRank::Icn::GenusGroup::Subgenus < NomenclaturalRank::Icn::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Icn::GenusGroup::Genus
  end

  def self.available_parents
    NomenclaturalRank::Icn::GenusGroup::Genus
  end

  def self.abbreviation
    "sgen."
  end
end
