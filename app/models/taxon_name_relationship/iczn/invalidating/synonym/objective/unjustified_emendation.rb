class TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation < TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000278'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::SynonymicHomonym,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::ReplacedHomonym)
  end

  def object_status
    'correct original spelling'
  end

  def subject_status
    'unjustified emendation'
  end

  def subject_status_connector_to_object
    ' for'
  end

  def self.assignment_method
    # bus.set_as_iczn_unjustified_emendation_of(aus)
    :iczn_set_as_unjustified_emendation_of
  end

  def self.inverse_assignment_method
    # aus.iczn_unjustified_emendation = bus
    :iczn_unjustified_emendation
  end

  protected

  def sv_specific_relationship
    s = self.subject_taxon_name
    o = self.object_taxon_name
    if s.name == o.name
      soft_validations.add(:base, "Unjustified emendation and correctly spelled names are identical: '#{s.cached_html}'")
    end
  end
end
