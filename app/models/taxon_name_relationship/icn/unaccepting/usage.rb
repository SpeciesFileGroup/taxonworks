class TaxonNameRelationship::Icn::Unaccepting::Usage < TaxonNameRelationship::Icn::Unaccepting

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000374'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting,
                          TaxonNameRelationship::Icn::Unaccepting::Homonym,
                          TaxonNameRelationship::Icn::Unaccepting::OriginallyInvalid,
                          TaxonNameRelationship::Icn::Unaccepting::Misapplication) +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Icn::Unaccepting::Synonym)
  end

  def subject_properties
    [ TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished ]
  end


end
