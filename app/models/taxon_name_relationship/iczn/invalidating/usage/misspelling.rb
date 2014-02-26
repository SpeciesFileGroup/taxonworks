class TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling < TaxonNameRelationship::Iczn::Invalidating::Usage

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_to_s(TaxonNameRelationship::Iczn::Invalidating::Usage::Misapplication,
                                      TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling)
  end

  def self.subject_relationship_name
    'correct spelling'
  end

  def self.object_relationship_name
    'misspelling'
  end


  def self.assignment_method
    # bus.set_as_misspelling_of(aus)
    :iczn_set_as_misspelling_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.misspelling = bus
    :iczn_misspelling
  end

  def self.assignable
    true
  end

end