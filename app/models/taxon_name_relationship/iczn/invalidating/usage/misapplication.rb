class TaxonNameRelationship::Iczn::Invalidating::Usage::Misapplication < TaxonNameRelationship::Iczn::Invalidating::Usage

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000274'

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_to_s(TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling,
                                      TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling)
  end

  def self.subject_relationship_name
    'correct application'
  end

  def self.object_relationship_name
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

end