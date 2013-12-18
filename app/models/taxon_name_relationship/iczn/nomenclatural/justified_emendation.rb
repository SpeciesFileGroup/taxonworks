class TaxonNameRelationship::Iczn::Nomenclatural::JustifiedEmendation < TaxonNameRelationship::Iczn::Nomenclatural

  def self.assignable
    true
  end

  def self.assignment_method
    # aus.iczn_justified_emendation = bus
    :iczn_justified_emendation
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_justified_emendation_of(aus)
    :set_as_justified_emendation_of
  end

end
