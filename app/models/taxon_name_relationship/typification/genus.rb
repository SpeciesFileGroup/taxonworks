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
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Typification::Family.to_s]
  end

  def object_status
    'type of genus'
  end

  def subject_status
    'type species'
  end

  def self.assignment_method
    # used like
    #    left_side_instance        right_side_instance
    #    species.type_of_genus(genus)
    :type_of_genus
  end

  def self.inverse_assignment_method
    # used like:
    #   right_side instance   =  left_side instance
    #   genus.type_species = species
    #   genus.type_species_relationship # => returns a TaxonNameRelationship
    :type_species
  end

  def self.assignable
    true
  end

  protected

  def validate_subject_and_object_ranks
    errors.add(:subject_taxon_name_id, 'Subject should be species-group name') if subject_taxon_name && !subject_taxon_name.is_species_rank?
    errors.add(:object_taxon_name_id, 'Object should be genus-group name') if object_taxon_name && !object_taxon_name.is_genus_rank?
  end

  def sv_not_specific_relationship
   soft_validations.add(:type, 'Please specify if the type designation is original or subsequent')
  end
end
