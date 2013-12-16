class TaxonNameRelationship::Typification::Genus::OriginalDesignation < TaxonNameRelationship::Typification::Genus

  # left side
  def self.valid_subject_ranks
    NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s}
  end

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Typification::Genus::Tautonomy.descendants.collect{|t| t.to_s} +
        TaxonNameRelationship::Typification::Genus::Monotypy.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Typification::Genus.to_s] +
        [TaxonNameRelationship::Typification::Genus::Tautonomy.to_s] +
        [TaxonNameRelationship::Typification::Genus::Monotypy] +
        [TaxonNameRelationship::Typification::Genus::SubsequentDesignation.to_s]
  end

  def self.assignment_method
    :type_species_by_original_designation 
  end

  def self.assignable
    true
  end

end
