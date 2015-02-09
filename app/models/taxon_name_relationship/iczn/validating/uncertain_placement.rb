class TaxonNameRelationship::Iczn::Validating::UncertainPlacement < TaxonNameRelationship::Iczn::Validating

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000266'

  # left_side
  def self.valid_subject_ranks
    GENUS_AND_SPECIES_RANK_NAMES_ICZN
  end

  # right_side
  def self.valid_object_ranks
    FAMILY_RANK_NAMES_ICZN
  end

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Iczn::Validating::ConservedName,
            TaxonNameRelationship::Iczn::Validating::ConservedWork)
  end

  def self.assignable
    true
  end

  def self.subject_relationship_name
    'incertae sedis'
  end

  def self.object_relationship_name
    'as incertae sedis'
  end

  def self.gbif_status_of_object
    'valid'
  end

  def self.assignment_method
    :iczn_uncertain_placement
  end

  def self.inverse_assignment_method
    # aus.iczn_uncertain_placement = Family
    :iczn_set_as_uncertain_placement_of
  end
end
