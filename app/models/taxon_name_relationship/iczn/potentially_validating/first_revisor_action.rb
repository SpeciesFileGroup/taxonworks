class TaxonNameRelationship::Iczn::PotentiallyValidating::FirstRevisorAction < TaxonNameRelationship::Iczn::PotentiallyValidating

  def self.assignable
    true
  end

  def self.subject_relationship_name
    'first revisor action'
  end

  def self.assignment_method
    # aus.iczn_first_revisor_action = bus
    :iczn_first_revisor_action
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_first_revisor_action_of(aus)
    :set_as_first_revisor_action_of
  end

end
