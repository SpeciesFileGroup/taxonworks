class  TaxonNameRelationship::Icnb::Unaccepting::Homonym <  TaxonNameRelationship::Icnb::Unaccepting

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000097'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icnb::Unaccepting) +
        self.collect_descendants_to_s(TaxonNameRelationship::Icnb::Unaccepting::Usage)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_to_s(TaxonNameClassification::Icnb::NotEffectivelyPublished) +
        self.collect_descendants_to_s(TaxonNameClassification::Icnb::EffectivelyPublished::InvalidlyPublished,
            TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Legitimate)
  end

  def subject_properties
    [ TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Illegitimate::Homonym ]
  end

  def object_status
    'homonym'
  end

  def subject_status
    'junior homonym'
  end

  def self.assignment_method
    # bus.set_as_icn_homonym_of(aus)
    :icnb_set_as_homonym_of
  end

  def self.inverse_assignment_method
    # aus.icn_homonym = bus
    :icnb_homonym
  end

end
