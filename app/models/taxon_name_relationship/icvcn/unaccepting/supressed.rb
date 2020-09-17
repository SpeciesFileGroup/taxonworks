class TaxonNameRelationship::Icvcn::Unaccepting::Supressed < TaxonNameRelationship::Icvcn::Unaccepting

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
    :icvcn_set_as_suppressed_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.iczn_suppression = bus
    :icvcn_suppressed
  end

  def sv_validate_priority
    date1 = self.subject_taxon_name.nomenclature_date
    date2 = self.object_taxon_name.nomenclature_date
    if !!date1 && !!date2 && date1 > date2 && subject_invalid_statuses.empty?
      soft_validations.add(:type, "#{self.subject_status.capitalize} #{self.subject_taxon_name.cached_html_name_and_author_year} should not be younger than #{self.object_taxon_name.cached_html_name_and_author_year}")
    end
  end
end
