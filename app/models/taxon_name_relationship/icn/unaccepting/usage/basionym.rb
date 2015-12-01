class TaxonNameRelationship::Icn::Unaccepting::Usage::Basionym < TaxonNameRelationship::Icn::Unaccepting::Usage

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000004'

  validates_uniqueness_of :subject_taxon_name_id, scope: :type

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling,
            TaxonNameRelationship::Icn::Unaccepting::Usage::Misapplication)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_to_s(TaxonNameClassification::Icn::NotEffectivelyPublished) +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
            TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate)
  end

  def subject_relationship_name
    'legitimate name'
  end

  def object_relationship_name
    'basionym'
  end

  def self.assignment_method
    # bus.set_as_icn_basionym_of(aus)
    :icn_set_as_basionym_of
  end

  def self.inverse_assignment_method
    # aus.icn_basionym = bus
    :icn_basionym
  end

end