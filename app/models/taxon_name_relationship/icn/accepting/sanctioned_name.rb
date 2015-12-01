class TaxonNameRelationship::Icn::Accepting::SanctionedName < TaxonNameRelationship::Icn::Accepting

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000035'

  def self.assignable
    true
  end

  def subject_relationship_name
    'rejected'
  end

  def object_relationship_name
    'sanctioned'
  end

  def self.gbif_status_of_subject
    'conservandum'
  end

  def self.gbif_status_of_object
    'rejiciendum'
  end

  def self.nomenclatural_priority
    :reverse
  end

  def self.assignment_method
    # bus.set_as_icn_sanctioned_name_of(aus)
    :icn_set_as_sanctioned_name_of
  end

  def self.inverse_assignment_method
    # aus.icn_sanctioned_name = bus
    :icn_sanctioned_name
  end

end