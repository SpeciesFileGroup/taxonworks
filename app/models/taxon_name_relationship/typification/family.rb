class TaxonNameRelationship::Typification::Family < TaxonNameRelationship::Typification

  # left side
  def self.valid_subject_ranks
    GENUS_RANK_NAMES
  end

  # right_side
  def self.valid_object_ranks
    FAMILY_RANK_NAMES
  end

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships + self.collect_descendants_and_itself_to_s(
        TaxonNameRelationship::Typification::Genus)
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
