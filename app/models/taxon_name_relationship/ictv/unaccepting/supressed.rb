class TaxonNameRelationship::Ictv::Unaccepting::Supressed < TaxonNameRelationship::Ictv::Unaccepting

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000123'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships
  end

  def object_status
    'conserved'
  end

  def subject_status
    'suppressed'
  end

  def subject_status_connector_to_object
    ' under'
  end

  def object_status_connector_to_subject
    ' for'
  end

  def self.gbif_status_of_subject
    'rejiciendum'
  end

  def self.gbif_status_of_object
    'conservandum'
  end

  def self.nomenclatural_priority
    :reverse
  end

  def self.assignment_method
    # bus.set_as_iczn_suppression_of(aus)
    :ictv_set_as_suppressed_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.iczn_suppression = bus
    :ictv_suppressed
  end
end
