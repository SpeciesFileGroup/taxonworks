class  TaxonNameRelationship::Icn::Unaccepting::Homonym <  TaxonNameRelationship::Icn::Unaccepting

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000391'

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting) +
        self.collect_descendants_to_s(TaxonNameRelationship::Icn::Unaccepting::Usage)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_to_s(TaxonNameClassification::Icn::NotEffectivelyPublished) +
        self.collect_descendants_to_s(TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
            TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate)
  end

  def self.subject_relationship_name
    'homonym'
  end

  def self.object_relationship_name
    'junior homonym'
  end

  def self.assignment_method
    # bus.set_as_icn_homonym_of(aus)
    :icn_set_as_homonym_of
  end

  def self.inverse_assignment_method
    # aus.icn_homonym = bus
    :icn_homonym
  end

end
