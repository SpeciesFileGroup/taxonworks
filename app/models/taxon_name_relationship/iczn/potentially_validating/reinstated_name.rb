class TaxonNameRelationship::Iczn::PotentiallyValidating::ReinstatedName < TaxonNameRelationship::Iczn::PotentiallyValidating

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000269'

  def subject_relationship_name
    'reinstated name'
  end

  def self.assignable
    true
  end

  def subject_relationship_name
    'as reinstated'
  end

  def object_relationship_name
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
