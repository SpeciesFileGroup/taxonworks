class TaxonNameRelationship::Iczn::Validating::UncertainPlacement < TaxonNameRelationship::Iczn::Validating

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Iczn::Validating::ConservedName.to_s]
  end

  def self.assignable
    true
  end

  def self.assignment_method
    # aus.iczn_uncertain_placement = Family
    :iczn_uncertain_placement
  end

  def self.object_relationship_name
    'incertae sedis'
  end

end
