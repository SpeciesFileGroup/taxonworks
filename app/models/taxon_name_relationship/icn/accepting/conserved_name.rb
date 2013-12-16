class TaxonNameRelationship::Icn::Accepting::ConservedName < TaxonNameRelationship::Icn::Accepting

  def self.assignable
    true
  end

  def self.assignment_method
    # aus.icn_conserved_name = bus
    :icn_conserved_name
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_icn_conserved_name_of(aus)
    :set_as_icn_conserved_name_of
  end

end
