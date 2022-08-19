class TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::ReplacedHomonym < TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000112'.freeze

  def self.disjoint_taxon_name_relationships
    parent.disjoint_taxon_name_relationships +
      self.collect_to_s(
        TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective,
        TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation,
        TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName,
        TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::SynonymicHomonym
      )
  end

  def self.assignment_method
    # bus.set_as_iczn_synonymic_homonym_of(aus)
    :iczn_set_as_replaced_homonym_of
  end

  def self.inverse_assignment_method
    # aus.iczn_synonymic_homonym = bus
    :iczn_replaced_homonym
  end
  
  def object_status
    'replacment name'
  end

  def subject_status
    'replaced'
  end

  def subject_status_connector_to_object
    ' by'
  end

  def object_status_connector_to_subject
    ' for'
  end

  def sv_specific_relationship
    tr = TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::ReplacedHomonym.where(object_taxon_name_id: subject_taxon_name_id).first
    unless tr.nil?
      soft_validations.add(:subject_taxon_name_id, "A new replacement name could not be proposed for another replacement name. The relationship should move from #{subject_taxon_name.cached_html} to the older objective synonym: #{tr.subject_taxon_name.cached_html}")
    end
  end

end
