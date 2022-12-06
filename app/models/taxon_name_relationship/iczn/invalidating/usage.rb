class TaxonNameRelationship::Iczn::Invalidating::Usage < TaxonNameRelationship::Iczn::Invalidating

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000273'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym,
            TaxonNameRelationship::Iczn::Invalidating::Homonym) +
            [TaxonNameRelationship::Iczn::Invalidating.to_s]
  end

  def self.assignable
    false
  end

  def subject_properties
    [ TaxonNameClassification::Iczn::Unavailable ]
  end

  def subject_status_connector_to_object
    ' of'
  end

  def sv_not_specific_relationship
    true
  end

  def sv_synonym_relationship
    true
  end

end
