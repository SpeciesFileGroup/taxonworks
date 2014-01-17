class TaxonNameRelationship::Typification::Family < TaxonNameRelationship::Typification

  # left side
  def self.valid_subject_ranks
    GENUS_RANKS_NAMES
  end

  # right_side
  def self.valid_object_ranks
    FAMILY_RANKS_NAMES
  end

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
    TaxonNameRelationship::Typification::Genus.descendants.collect{|t| t.to_s} +
    [TaxonNameRelationship::Typification::Genus.to_s]
  end

  def self.subject_relationship_name
    'type genus'
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
