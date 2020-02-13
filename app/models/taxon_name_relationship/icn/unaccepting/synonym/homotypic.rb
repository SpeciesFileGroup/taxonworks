class TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic < TaxonNameRelationship::Icn::Unaccepting::Synonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000393'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting::Synonym,
            TaxonNameRelationship::Icn::Unaccepting::Synonym::Heterotypic)
  end

  def object_status
    'homotypic senior synonym'
  end

  def subject_status
    'homotypic synonym'
  end

  def self.assignment_method
    # bus.set_as_icn_homotypic_synonym_of(aus)
    :icn_set_as_homotypic_synonym_of
  end

  def self.inverse_assignment_method
    # aus.icn_homotypic_synonym = bus
    :icn_homotypic_synonym
  end

  def sv_objective_synonym_relationship
    s = self.subject_taxon_name
    o = self.object_taxon_name
    if (s.type_taxon_name != o.type_taxon_name ) || !s.has_same_primary_type(o)
      soft_validations.add(:type, "Homotypic synonyms #{s.cached_html} and #{o.cached_html} should have the same type")
    end
  end

  def sv_not_specific_relationship
    true
  end
end