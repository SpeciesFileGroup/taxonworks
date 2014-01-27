class TaxonNameRelationship::Typification::Genus::SubsequentDesignation < TaxonNameRelationship::Typification::Genus

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
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Typification::Genus::Tautonomy,
            TaxonNameRelationship::Typification::Genus::Monotypy) +
        self.collect_to_s(TaxonNameRelationship::Typification::Genus,
            TaxonNameRelationship::Typification::Genus::OriginalDesignation,
            TaxonNameRelationship::Typification::Genus::RulingByCommission)
  end

  def self.subject_relationship_name
    'type of genus by subsequent designation'
  end

  def self.object_relationship_name
    'type species by subsequent designation'
  end

  def self.assignment_method
    :type_of_genus_by_subsequent_designation
  end

  def self.inverse_assignment_method
    :type_species_by_subsequent_designation
  end

end
