class TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::Basionym < TaxonNameRelationship::Icn::Unaccepting::Usage

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000004'.freeze

  validates_uniqueness_of :subject_taxon_name_id, scope: :type

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
      self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic,
                        TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::Isonym,
                        TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::OrthographicVariant,
                        TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::AlternativeName)
  end
  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_to_s(TaxonNameClassification::Icn::NotEffectivelyPublished) +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
            TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate)
  end

  def object_status
    'legitimate name'
  end

  def subject_status
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

  def self.nomenclatural_priority
    :reverse
  end


end