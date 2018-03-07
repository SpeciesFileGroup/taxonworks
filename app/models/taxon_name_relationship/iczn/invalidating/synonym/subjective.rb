class TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective < TaxonNameRelationship::Iczn::Invalidating::Synonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000285'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName)
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

end
