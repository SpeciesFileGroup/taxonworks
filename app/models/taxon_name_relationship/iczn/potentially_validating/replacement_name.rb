class TaxonNameRelationship::Iczn::PotentiallyValidating::ReplacementName < TaxonNameRelationship::Iczn::PotentiallyValidating

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000270'.freeze

  def self.assignable
    true
  end

  def object_status
    'replaced with'
  end

  def subject_status
    'nomen novum'
  end

  def self.gbif_status_of_subject
    'novum'
  end

  # as.
  def self.assignment_method
    # bus.set_as_replacement_name_of(aus)
    :iczn_set_as_replacement_name_of
  end

  def self.inverse_assignment_method
    # aus.iczn_replacement_name = bus
    :iczn_replacement_name
  end

  def self.nomenclatural_priority
    :direct
  end
end
