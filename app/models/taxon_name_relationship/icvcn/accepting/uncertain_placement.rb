class TaxonNameRelationship::Icvcn::Accepting::UncertainPlacement < TaxonNameRelationship::Icvcn

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000124'.freeze

  def self.assignable
    true
  end

  def object_status
    'incertae sedis for'
  end

  def subject_status
    'incertae sedis'
  end

  def self.gbif_status_of_object
    'valid'
  end

  def subject_status_connector_to_object
    ' in'
  end

  def self.assignment_method
    #species.iczn_uncertain_placement = family
    :icvcn_uncertain_placement
  end

  def self.inverse_assignment_method
    # family.iczn_set_as_uncertain_placement_of = species
    :icvcn_set_as_uncertain_placement_of
  end
end