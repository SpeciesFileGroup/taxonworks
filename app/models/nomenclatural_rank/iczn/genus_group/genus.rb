class NomenclaturalRank::Iczn::GenusGroup::Genus < NomenclaturalRank::Iczn::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::GenusGroup::Supergenus
  end

  def self.abbreviation
    'gen.'
  end
end
