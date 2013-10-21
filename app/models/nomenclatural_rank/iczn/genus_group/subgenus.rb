class NomenclaturalRank::Iczn::GenusGroup::Subgenus < NomenclaturalRank::Iczn::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::GenusGroup::Genus
  end

  def self.available_parent
    NomenclaturalRank::Iczn::GenusGroup::Genus
  end

  def self.abbreviation
    'sgen.'
  end
end
