class TaxonNameRelationship::Icnb::Unaccepting::Usage < TaxonNameRelationship::Icnb::Unaccepting

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000098'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icnb::Unaccepting,
            TaxonNameRelationship::Icnb::Unaccepting::Homonym) +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Icnb::Unaccepting::Synonym)
  end

  def subject_properties
    [ TaxonNameClassification::Icnb::EffectivelyPublished::InvalidlyPublished ]
  end


end