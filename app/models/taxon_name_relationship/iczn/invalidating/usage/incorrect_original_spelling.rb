class TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling < TaxonNameRelationship::Iczn::Invalidating::Usage

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000044'

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_to_s(TaxonNameRelationship::Iczn::Invalidating::Usage::Misapplication,
                                      TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling)
  end

  def self.subject_relationship_name
    'justified emendation'
  end

  def self.object_relationship_name
    'incorrect original spelling'
  end

  def self.gbif_status_of_subject
    'negatum'
  end

  def self.assignment_method
    # bus.set_as_misspelling_of(aus)
    :iczn_set_as_incorrect_original_spelling_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.misspelling = bus
    :iczn_incorrect_original_spelling
  end

  def self.nomenclatural_priority
    nil
  end

  def self.assignable
    true
  end

end