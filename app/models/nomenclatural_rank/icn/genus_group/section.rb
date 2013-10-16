class NomenclaturalRank::Icn::GenusGroup::Section < NomenclaturalRank::Icn::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Icn::GenusGroup::Subgenus
  end

  def self.abbreviation
    "sect."
  end
end
