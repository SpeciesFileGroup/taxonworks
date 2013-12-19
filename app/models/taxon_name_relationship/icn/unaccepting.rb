class TaxonNameRelationship::Icn::Unaccepting < TaxonNameRelationship::Icn

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Icn::Accepting.descendants.collect{|t| t.to_s}
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
        [TaxonNameClass::Icn::NotEffectivelyPublished.to_s] +
        TaxonNameClass::Icn::EffectivelyPublished::InvalidlyPublished.descendants.collect{|t| t.to_s} +
        TaxonNameClass::Iczn::EffectivelyPublished::ValidlyPublished::Illegitimate.descendants.collect{|t| t.to_s}
  end


  def self.assignable
    true
  end

  def self.assignment_method
    # aus.icn_unacceptable = bus
    :icn_unacceptable
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_icn_unacceptable_of(aus)
    :set_as_icn_unacceptable_of
  end

end