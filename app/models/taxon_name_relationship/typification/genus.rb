class TaxonNameRelationship::Typification::Genus < TaxonNameRelationship::Typification

   # left side
  def self.valid_subject_ranks
    SPECIES_RANK_NAMES
  end

   # right_side
  def self.valid_object_ranks
    GENUS_RANK_NAMES
  end

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships + self.collect_to_s(
        TaxonNameRelationship::Typification::Family)
  end

  def self.subject_relationship_name
    'type species'
  end

  def self.assignment_method
    # used like:
    #
    #   right_side instance   =  left_side instance
    #   genus.type_species = species
    #   genus.type_species_relationship # => returns a TaxonNameRelationship
    :type_species
  end

  def self.inverse_assignment_method
    # used like
    #    left_side_instance        right_side_instance
    #    species.type_of_genus(genus)
    :type_of_genus
  end

  def self.assignable
    true
  end

end
