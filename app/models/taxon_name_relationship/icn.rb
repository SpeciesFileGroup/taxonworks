class TaxonNameRelationship::Icn < TaxonNameRelationship

  # left_side
  def self.valid_subject_ranks
    NomenclaturalRank::Icn.descendants.collect{|t| t.to_s}
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Icn.descendants.collect{|t| t.to_s}
  end

  def self.assignable
    false
  end

end
