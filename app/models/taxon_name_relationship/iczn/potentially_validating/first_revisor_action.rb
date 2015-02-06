class TaxonNameRelationship::Iczn::PotentiallyValidating::FirstRevisorAction < TaxonNameRelationship::Iczn::PotentiallyValidating

  NOMEN_URI=''

  def self.assignable
    true
  end

  def self.subject_relationship_name
    'first revisor action'
  end

  def self.object_relationship_name
    'first revisor action'
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
