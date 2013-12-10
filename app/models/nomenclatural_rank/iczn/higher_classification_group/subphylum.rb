class NomenclaturalRank::Iczn::HigherClassificationGroup::Subphylum < NomenclaturalRank::Iczn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::HigherClassificationGroup::Phylum
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::HigherClassificationGroup::Phylum.to_s]
  end

end
