class TaxonNameRelationship::Ictv::Accepting < TaxonNameRelationship::Ictv

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000121'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Ictv::Unaccepting)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Ictv::Invalid,
                                                 TaxonNameClassification::Ictv::Valid::Unaccepted)
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Ictv::Valid::Unaccepted)
  end

  def subject_status_connector_to_object
    ' for'
  end

  def object_status
    'accepted'
  end

  def subject_status
    'unaccepted'
  end

  def self.gbif_status_of_subject
    'valid'
  end

  def self.gbif_status_of_object
    'invalidum'
  end
end