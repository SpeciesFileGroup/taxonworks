class TaxonNameRelationship::Iczn::Validating::ConservedName < TaxonNameRelationship::Iczn::Validating

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Iczn::Validating::UncertainPlacement.to_s]
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        [TaxonNameClassification::Iczn::Available::Valid::NomenDubium.to_s]
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
        [TaxonNameClassification::Iczn::Available::Invalid.to_s] +
        [TaxonNameClassification::Iczn::Available::Valid.to_s]
  end

  def self.assignable
    true
  end

  def self.subject_relationship_name
    'conserved name'
  end

  def self.object_relationship_name
    'suppressed name'
  end


  def self.assignment_method
    # aus.iczn_conserved_name = bus
    :iczn_conserved_name
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_conserved_name_of(aus)
    :set_as_conserved_name_of
  end

end
