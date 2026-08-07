class TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName < TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000279'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::SynonymicHomonym,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::ReplacedHomonym)
  end

  def object_status
    'replaced'
  end

  def subject_status
    'unnecessary replacement'
  end

  def subject_status_connector_to_object
    ' for'
  end

  def object_status_connector_to_subject
    ' by'
  end

  def self.gbif_status_of_subject
    'superfluum'
  end

  def self.assignment_method
    # bus.set_as_iczn_unnecessary_replacement_name_of(aus)
    :iczn_set_as_unnecessary_replaced_name
  end

  def self.inverse_assignment_method
    # aus.iczn_unnecessary_replacement_name = bus
    :iczn_unnecessary_replacement_name
  end

end
