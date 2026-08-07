class TaxonNameRelationship::Icn::Unaccepting::Misapplication < TaxonNameRelationship::Icn::Unaccepting

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000376'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting::Synonym,
            TaxonNameRelationship::Icn::Unaccepting::Homonym,
            TaxonNameRelationship::Icn::Unaccepting::Usage,
            TaxonNameRelationship::Icn::Unaccepting::OriginallyInvalid)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_to_s(TaxonNameClassification::Icn::NotEffectivelyPublished) +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
            TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate)
  end

  def subject_properties
    [ TaxonNameClassification::Icn::NotEffectivelyPublished ]
  end


  def object_status
    'correct application'
  end

  def subject_status
    'misapplication'
  end

  def self.gbif_status_of_subject
    'ambigua'
  end

  def self.assignment_method
    # bus.set_as_icn_misapplication_of(aus)
    :icn_set_as_misapplication_of
  end

  def self.inverse_assignment_method
    # aus.icn_misapplication = bus
    :icn_misapplication
  end

end
