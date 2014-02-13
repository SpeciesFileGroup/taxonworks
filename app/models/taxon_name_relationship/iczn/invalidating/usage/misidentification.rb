class TaxonNameRelationship::Iczn::Invalidating::Usage::Misidentification < TaxonNameRelationship::Iczn::Invalidating::Usage

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_to_s(TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling,
                                      TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling)
  end

  def self.subject_relationship_name
    'correct identification'
  end

  def self.object_relationship_name
    'misidentification'
  end


  def self.assignment_method
    # bus.set_as_iczn_misidentification_of(aus)
    :iczn_set_as_misidentification_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.iczn_misidentification = bus
    :iczn_misidentification
  end

  def self.assignable
    true
  end

  def self.nomenclatural_priority
    nil
  end

end