class TaxonNameRelationship::Icnb::Unaccepting::Synonym::Objective < TaxonNameRelationship::Icnb::Unaccepting::Synonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000101'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icnb::Unaccepting::Synonym,
                          TaxonNameRelationship::Icnb::Unaccepting::Synonym::Subjective)
  end

  def object_status
    'objective senior synonym'
  end

  def subject_status
    'objective synonym'
  end

  def self.assignment_method
    # bus.set_as_icn_homotypic_synonym_of(aus)
    :icnb_set_as_objective_synonym_of
  end

  def self.inverse_assignment_method
    # aus.icn_homotypic_synonym = bus
    :icnb_objective_synonym
  end

end