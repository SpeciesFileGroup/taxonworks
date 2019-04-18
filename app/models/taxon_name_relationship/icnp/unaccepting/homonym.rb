class  TaxonNameRelationship::Icnp::Unaccepting::Homonym <  TaxonNameRelationship::Icnp::Unaccepting

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000097'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icnp::Unaccepting) +
        self.collect_descendants_to_s(TaxonNameRelationship::Icnp::Unaccepting::Usage)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_to_s(TaxonNameClassification::Icnp::NotEffectivelyPublished) +
        self.collect_descendants_to_s(TaxonNameClassification::Icnp::EffectivelyPublished::InvalidlyPublished,
            TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Legitimate)
  end

  def subject_properties
    [ TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Illegitimate::Homonym ]
  end

  def object_status
    'earlier homonym'
  end

  def subject_status
    'later homonym'
  end

  def self.assignment_method
    # bus.set_as_icn_homonym_of(aus)
    :icnp_set_as_homonym_of
  end

  def self.inverse_assignment_method
    # aus.icn_homonym = bus
    :icnp_homonym
  end

end
