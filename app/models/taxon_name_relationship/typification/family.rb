class TaxonNameRelationship::Typification::Family < TaxonNameRelationship::Typification

  # left side
  def self.valid_subject_ranks
    NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Icn::GenusGroup.descendants.collect{|t| t.to_s}
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Icn::FamilyGroup.descendants.collect{|t| t.to_s}
  end

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
    TaxonNameRelationship::Typification::Genus.descendants.collect{|t| t.to_s} +
    [TaxonNameRelationship::Typification::Genus.to_s]
  end

  def self.assignment_method
    :type_genus
  end

  def self.inverse_assignment_method
    :type_of_family
  end

  def self.assignable
    true
  end

end
