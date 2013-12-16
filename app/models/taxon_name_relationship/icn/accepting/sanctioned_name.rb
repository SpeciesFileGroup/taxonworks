class TaxonNameRelationship::Icn::Accepting::SanctionedName < TaxonNameRelationship::Icn::Accepting

  def self.assignable
    true
  end

  def self.assignment_method
    # aus.icn_sanctioned_name = bus
    :icn_sanctioned_name
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_icn_sanctioned_name_of(aus)
    :set_as_icn_sanctioned_name_of
  end

end