class TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName < TaxonNameRelationship::Iczn::Invalidating::Synonym

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective)
  end

  def self.subject_relationship_name
    'nomen protectum'
  end

  def self.object_relationship_name
    'nomen oblitum'
  end

  def self.gbif_status_of_subject
    'oblitum'
  end

  def self.nomenclatural_priority
    :reverse
  end

  def self.assignment_method
    # bus.set_as_iczn_forgotten_name_of(aus)
    :iczn_set_as_forgotten_name_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.iczn_forgotten_name = bus
    :iczn_forgotten_name
  end

end
