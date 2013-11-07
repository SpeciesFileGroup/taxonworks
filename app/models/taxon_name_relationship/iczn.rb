class TaxonNameRelationship::Iczn < TaxonNameRelationship

  # left_side
  def self.valid_subject_ranks
    NomenclaturalRank::Iczn.descendants
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn.descendants
  end

  def assignable
    false
  end

end
