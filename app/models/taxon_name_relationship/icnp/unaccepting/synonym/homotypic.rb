class TaxonNameRelationship::Icnp::Unaccepting::Synonym::Homotypic < TaxonNameRelationship::Icnp::Unaccepting::Synonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000101'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icnp::Unaccepting::Synonym,
                          TaxonNameRelationship::Icnp::Unaccepting::Synonym::Heterotypic)
  end

  def object_status
    'homotypic earlier synonym'
  end

  def subject_status
    'homotypic later synonym'
  end

  def self.assignment_method
    # bus.set_as_icn_homotypic_synonym_of(aus)
    :icnp_set_as_objective_synonym_of
  end

  def self.inverse_assignment_method
    # aus.icn_homotypic_synonym = bus
    :icnp_objective_synonym
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