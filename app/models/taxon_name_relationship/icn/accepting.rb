class TaxonNameRelationship::Icn::Accepting < TaxonNameRelationship::Icn

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000370'


  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Icn::Unaccepting)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_descendants_to_s(TaxonNameClassification::Icn::NotEffectivelyPublished,
        TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
        TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate)
  end

  def self.gbif_status_of_subject
    'valid'
  end

  def self.gbif_status_of_object
    'invalidum'
  end

end