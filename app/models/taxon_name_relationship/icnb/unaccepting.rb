class TaxonNameRelationship::Icnb::Unaccepting < TaxonNameRelationship::Icnb

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000093'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_to_s(TaxonNameRelationship::Icnb::Accepting)
  end

  def subject_properties
    [ TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Illegitimate ]
  end

  def object_status
    'accepted name'
  end

  def subject_status
    'unaccepted name'
  end

  def self.gbif_status_of_subject
    'invalidum'
  end

  def self.gbif_status_of_object
    'valid'
  end

  def self.assignment_method
    # bus.set_as_icn_unacceptable_of(aus)
    :icnb_set_as_unacceptable_of
  end

  def self.inverse_assignment_method
    # aus.icn_unacceptable = bus
    :icnb_unacceptable
  end

  def self.nomenclatural_priority
    :direct
  end

  def self.assignable
    true
  end

end