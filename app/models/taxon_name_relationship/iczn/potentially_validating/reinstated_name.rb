class TaxonNameRelationship::Iczn::PotentiallyValidating::ReinstatedName < TaxonNameRelationship::Iczn::PotentiallyValidating

  def self.subject_relationship_name
    'reinstated name'
  end

  def self.assignable
    true
  end

  def self.subject_relationship_name
    'as reinstated'
  end

  def self.object_relationship_name
    'reinstated'
  end

  def self.assignment_method
    # aus.iczn_reinstated_name = bus
    :iczn_set_as_reinstated_name_of
  end

  def self.inverse_assignment_method
    # aus.iczn_reinstated_name = bus
    :iczn_reinstated_name
  end
end
