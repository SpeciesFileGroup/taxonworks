class TaxonNameRelationship::Icn::Unaccepting::Synonym < TaxonNameRelationship::Icn::Unaccepting

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships + self.collect_to_s(
        TaxonNameRelationship::Icn::Unaccepting) + self.collect_descendants_to_s(
        TaxonNameRelationship::Icn::Unaccepting::Usage)
  end

  def self.subject_relationship_name
    'synonym'
  end

  def self.object_relationship_name
    'senior synonym'
  end


  def self.assignment_method
    # aus.icn_synonym = bus
    :icn_synonym
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_icn_synonym_of(aus)
    :set_as_icn_synonym_of
  end

end