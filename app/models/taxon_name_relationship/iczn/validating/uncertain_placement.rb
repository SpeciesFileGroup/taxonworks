class TaxonNameRelationship::Iczn::Validating::UncertainPlacement < TaxonNameRelationship::Iczn::Validating

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000266'.freeze

  # left_side
  def self.valid_subject_ranks
    GENUS_AND_SPECIES_RANK_NAMES_ICZN
  end

  # right_side
  def self.valid_object_ranks
    FAMILY_AND_ABOVE_RANK_NAMES_ICZN + ['NomenclaturalRank::Iczn::GenusGroup::Supergenus']
  end

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Iczn::Validating::ConservedName,
            TaxonNameRelationship::Iczn::Validating::ConservedWork)
  end

  def self.assignable
    true
  end

  def object_status
    'incertae sedis for'
  end

  def subject_status
    'incertae sedis'
  end

  def self.gbif_status_of_object
    'valid'
  end

  def subject_status_connector_to_object
    ' in'
  end

  def self.assignable
    true
  end

  #species.iczn_uncertain_placement = family
  def self.assignment_method
    :iczn_uncertain_placement
  end

  # family.iczn_set_as_uncertain_placement_of = species
  def self.inverse_assignment_method
    :iczn_set_as_uncertain_placement_of
  end
end
