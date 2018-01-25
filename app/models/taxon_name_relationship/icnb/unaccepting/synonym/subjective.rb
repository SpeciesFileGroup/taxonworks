class TaxonNameRelationship::Icnb::Unaccepting::Synonym::Subjective < TaxonNameRelationship::Icnb::Unaccepting::Synonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000102'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icnb::Unaccepting::Synonym) +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Icnb::Unaccepting::Synonym::Objective)
  end

  def object_status
    'subjective senior synonym'
  end

  def subject_status
    'subjective synonym'
  end

  def self.assignment_method
    # bus.set_as_icn_heterotypic_synonym_of(aus)
    :icnb_set_as_subjective_synonym_of
  end

  def self.inverse_assignment_method
    # aus.icn_heterotypic_synonym = bus
    :icnb_subjective_synonym
  end

end