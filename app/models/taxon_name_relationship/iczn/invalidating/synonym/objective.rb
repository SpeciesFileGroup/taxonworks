class TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective < TaxonNameRelationship::Iczn::Invalidating::Synonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000277'

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName)
  end

  def subject_relationship_name
    'objective senior synonym'
  end

  def object_relationship_name
    'objective synonym'
  end

  def self.assignment_method
    # bus.set_as_iczn_objective_synonym_of(aus)
    :iczn_set_as_objective_synonym_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.iczn_objective_synonym = bus
    :iczn_objective_synonym
  end

end
