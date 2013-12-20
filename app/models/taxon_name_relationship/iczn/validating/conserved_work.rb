class TaxonNameRelationship::Iczn::Validating::ConservedWork < TaxonNameRelationship::Iczn::Validating

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Iczn::Validating::UncertainPlacement.to_s]
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        [TaxonNameClass::Iczn::Available::Valid::NomenDubium.to_s]
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
        [TaxonNameClass::Iczn::Available::Invalid.to_s] +
        [TaxonNameClass::Iczn::Available::Valid.to_s]
  end

  def self.assignable
    true
  end

  def self.subject_relationship_name
    'conserved work'
  end

  def self.object_relationship_name
    'suppressed work'
  end

  def self.assignment_method
    # aus.iczn_conserved_name = bus
    :iczn_conserved_work
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_conserved_name_of(aus)
    :set_as_conserved_conserved_of
  end

end