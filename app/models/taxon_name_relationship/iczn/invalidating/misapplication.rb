class TaxonNameRelationship::Iczn::Invalidating::Misapplication < TaxonNameRelationship::Iczn::Invalidating

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000274'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym,
                                      TaxonNameRelationship::Iczn::Invalidating::Homonym)
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
      self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Unavailable)
  end

  def subject_properties
    [ TaxonNameClassification::Iczn::Unavailable ]
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
    # bus.set_as_iczn_misapplication_of(aus)
    :iczn_set_as_misapplication_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.iczn_misapplication = bus
    :iczn_misapplication
  end

  def self.assignable
    true
  end

  def self.nomenclatural_priority
    nil
  end

  def sv_not_specific_relationship
    true
  end
end
