class TaxonNameRelationship::Iczn::Nomenclatural::ReinstatedName < TaxonNameRelationship::Iczn::Nomenclatural

  def self.assignable
    true
  end

  def self.assignment_method
    # aus.iczn_reinstated_name = bus
    :iczn_reinstated_name
  end

end
