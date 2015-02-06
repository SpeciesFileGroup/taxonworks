class TaxonNameRelationship::Icn::Unaccepting < TaxonNameRelationship::Icn

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000369'

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_to_s(TaxonNameRelationship::Icn::Accepting)
  end

  def self.subject_relationship_name
    'accepted name'
  end

  def self.object_relationship_name
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
    :icn_set_as_unacceptable_of
  end

  def self.inverse_assignment_method
    # aus.icn_unacceptable = bus
    :icn_unacceptable
  end

  def self.nomenclatural_priority
    :direct
  end

  def self.assignable
    true
  end

end