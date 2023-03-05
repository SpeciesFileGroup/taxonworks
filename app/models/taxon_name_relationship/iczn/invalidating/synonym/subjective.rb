class TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective < TaxonNameRelationship::Iczn::Invalidating::Synonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000285'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym)
  end

  def object_status
    'senior subjective synonym'
  end

  def subject_status
    'subjective synonym'
  end

  def self.assignment_method
    # bus.set_as_iczn_subjective_synonym_of(aus)
    :iczn_set_as_subjective_synonym_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.iczn_subjective_synonym = bus
    :iczn_subjective_synonym
  end

  def sv_specific_relationship
    s = subject_taxon_name
    o = object_taxon_name
    if (s.type_taxon_name == o.type_taxon_name && !s.type_taxon_name.nil? ) || (!s.get_primary_type.empty? && s.has_same_primary_type(o) )
      soft_validations.add(:type, "Subjective synonyms #{s.cached_html} and #{o.cached_html} should not have the same type")
    end
  end

  def sv_not_specific_relationship
    true
  end
end
