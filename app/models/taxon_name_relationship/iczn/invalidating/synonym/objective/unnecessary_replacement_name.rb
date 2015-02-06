class TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName < TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000279'

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::SynonymicHomonym)
  end

  def self.subject_relationship_name
    'unnecessary replaced'
  end

  def self.object_relationship_name
    'unnecessary replacement'
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
