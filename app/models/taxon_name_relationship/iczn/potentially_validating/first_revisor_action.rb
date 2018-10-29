class TaxonNameRelationship::Iczn::PotentiallyValidating::FirstRevisorAction < TaxonNameRelationship::Iczn::PotentiallyValidating

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000271'.freeze

  # Override priority test
  def sv_validate_priority
    unless self.type_class.nomenclatural_priority.nil?
      date1 = self.subject_taxon_name.nomenclature_date
      date2 = self.object_taxon_name.nomenclature_date
      unless date1 == date2
        soft_validations.add(:type, 'Both taxa should be described on the same date')
        soft_validations.add(:object_taxon_name_id, 'Taxon has different publication date')
      end
    end
  end

  def self.assignable
    true
  end

  def object_status
    'does not have priority as a result of the first revisor action'
  end

  def subject_status_connector_to_object
    ' over'
  end

  def subject_status
    'has priority as a result of the first revisor action'
  end

  def object_status_connector_to_subject
    ' under'
  end

  def self.nomenclatural_priority
    :direct # will validate for the date is equal
  end

  def self.assignment_method
    # bus.set_as_first_revisor_action_of(aus)
    :iczn_set_as_first_revisor_action_of
  end

  def self.inverse_assignment_method
    # aus.iczn_first_revisor_action = bus
    :iczn_first_revisor_action
  end

end
