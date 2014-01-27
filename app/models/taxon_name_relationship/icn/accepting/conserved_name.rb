class TaxonNameRelationship::Icn::Accepting::ConservedName < TaxonNameRelationship::Icn::Accepting

  def self.assignable
    true
  end

  def self.subject_relationship_name
    'rejected'
  end

  def self.object_relationship_name
    'conserved'
  end

  def self.nomenclatural_priority
    :reverse
  end

  def self.assignment_method
    # bus.set_as_icn_conserved_name_of(aus)
    :icn_set_as_conserved_name_of
  end

  def self.inverse_assignment_method
    # aus.icn_conserved_name = bus
    :icn_conserved_name
  end

end
