class TaxonNameRelationship::Typification::Genus::Tautonomy < TaxonNameRelationship::Typification::Genus

  # left side
  def self.valid_subject_ranks
    SPECIES_RANK_NAMES_ICZN
  end

  # right_side
  def self.valid_object_ranks
    GENUS_RANK_NAMES_ICZN
  end

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
    TaxonNameRelationship::Typification::Genus::Monotypy.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Typification::Genus.to_s] +
        [TaxonNameRelationship::Typification::Genus::Monotypy.to_s] +
        [TaxonNameRelationship::Typification::Genus::SubsequentDesignation.to_s] +
        [TaxonNameRelationship::Typification::Genus::SubsequentDesignation.to_s]
  end

  def self.subject_relationship_name
    'type species by tautonomy'
  end

  def self.assignment_method
    :type_species_by_tautonomy
  end

end
