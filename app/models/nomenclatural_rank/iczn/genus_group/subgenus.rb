class NomenclaturalRank::Iczn::GenusGroup::Subgenus < NomenclaturalRank::Iczn::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::GenusGroup::Genus
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::GenusGroup::Genus.to_s]
  end

  def self.abbreviation
    'sgen.'
  end
end
