class TaxonNameRelationship::Icn::Unaccepting::Synonym < TaxonNameRelationship::Icn::Unaccepting

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Icn::Unaccepting::Usage.descendants.collect{|t| t.to_s}
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