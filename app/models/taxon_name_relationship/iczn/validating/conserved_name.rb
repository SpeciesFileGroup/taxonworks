class TaxonNameRelationship::Iczn::Validating::ConservedName < TaxonNameRelationship::Iczn::Validating

  def self.assignable
    true
  end

  def self.assignment_method
    # aus.iczn_conserved_name = bus
    :iczn_conserved_name
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_conserved_name_of(aus)
    :set_as_conserved_name_of
  end

end
