class TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Total < TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000283'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating::Homonym) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Partial,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Conditional)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_to_s(TaxonNameClassification::Iczn::Available::OfficialListOfFamilyGroupNamesInZoology,
                          TaxonNameClassification::Iczn::Available::OfficialListOfGenericNamesInZoology,
                          TaxonNameClassification::Iczn::Available::OfficialListOfWorksApprovedAsAvailable)
  end

  def object_status
    'conserved'
  end

  def subject_status
    'totally suppressed'
  end

  def self.assignment_method
    # bus.set_as_iczn_total_suppression_of(aus)
    :iczn_set_as_total_suppression_of
  end

  def self.inverse_assignment_method
    # aus.iczn_total_suppression = bus
    :iczn_total_suppression
  end

  def sv_not_specific_relationship
    true
  end
end