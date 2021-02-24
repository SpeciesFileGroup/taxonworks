class NomenclaturalRank::Iczn::GenusGroup::Supersupersubgenus < NomenclaturalRank::Iczn::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::GenusGroup::Genus
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::GenusGroup::Genus.to_s]
  end

  def self.abbreviation
    'supersupersubgen.'
  end

  def self.typical_use
    false
  end

end
