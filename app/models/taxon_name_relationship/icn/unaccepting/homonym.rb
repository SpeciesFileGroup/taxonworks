class  TaxonNameRelationship::Icn::Unaccepting::Homonym <  TaxonNameRelationship::Icn::Unaccepting

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000391'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting,
                          TaxonNameRelationship::Icn::Unaccepting::OriginallyInvalid,
                          TaxonNameRelationship::Icn::Unaccepting::Misapplication) +
        self.collect_descendants_to_s(TaxonNameRelationship::Icn::Unaccepting::Usage)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_to_s(TaxonNameClassification::Icn::NotEffectivelyPublished) +
        self.collect_descendants_to_s(TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
            TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate)
  end

  def subject_properties
    [ TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate::Homonym ]
  end

  def object_status
    'homonym'
  end

  def subject_status
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
