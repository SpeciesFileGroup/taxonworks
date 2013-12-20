class TaxonNameRelationship::Iczn::PotentiallyValidating::ReplacementName < TaxonNameRelationship::Iczn::PotentiallyValidating

  def self.assignable
    true
  end

  def self.subject_relationship_name
    'nomen novum'
  end

  def self.object_relationship_name
    'homonym'
  end


  def self.assignment_method
    # aus.iczn_replacement_name = bus
    :iczn_replacement_name
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_replacement_name_of(aus)
    :set_as_replacement_name_of
  end

end
