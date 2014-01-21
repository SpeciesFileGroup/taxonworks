class  TaxonNameRelationship::Icn::Unaccepting::Homonym <  TaxonNameRelationship::Icn::Unaccepting

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships + self.collect_to_s(
        TaxonNameRelationship::Icn::Unaccepting) + self.collect_descendants_to_s(
        TaxonNameRelationship::Icn::Unaccepting::Usage)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subbject_classes +
        [TaxonNameClassification::Icn::NotEffectivelyPublished.to_s] +
        TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished.descendants.collect{|t| t.to_s} +
        TaxonNameClassification::Iczn::EffectivelyPublished::ValidlyPublished::Legitimate.descendants.collect{|t| t.to_s}
  end

  def self.subject_relationship_name
    'homonym'
  end

  def self.object_relationship_name
    'senior homonym'
  end


  def self.assignment_method
    # aus.icn_homonym = bus
    :icn_homonym
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_icn_homonym_of(aus)
    :set_as_icn_homonym_of
  end

end
