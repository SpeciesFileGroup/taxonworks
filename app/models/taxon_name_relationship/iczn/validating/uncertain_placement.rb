class TaxonNameRelationship::Iczn::Validating::UncertainPlacement < TaxonNameRelationship::Iczn::Validating

  def self.assignable
    true
  end

  def self.assignment_method
    # aus.iczn_uncertain_placement = Family
    :iczn_uncertain_placement
  end

end
