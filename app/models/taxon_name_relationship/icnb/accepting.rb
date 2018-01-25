class TaxonNameRelationship::Icnb::Accepting < TaxonNameRelationship::Icnb

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000094'.freeze


  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Icnb::Unaccepting)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_descendants_to_s(TaxonNameClassification::Icnb::NotEffectivelyPublished,
                                      TaxonNameClassification::Icnb::EffectivelyPublished::InvalidlyPublished,
                                      TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Illegitimate)
  end

  def subject_properties
    [ TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Legitimate ]
  end

  def self.gbif_status_of_subject
    'valid'
  end

  def self.gbif_status_of_object
    'invalidum'
  end

end