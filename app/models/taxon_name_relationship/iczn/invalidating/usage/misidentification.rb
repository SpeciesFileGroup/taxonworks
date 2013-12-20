class TaxonNameRelationship::Iczn::Invalidating::Usage::Misidentification < TaxonNameRelationship::Iczn::Invalidating::Usage

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling.descendants.collect{|t| t.to_s}
  end

  def self.subject_relationship_name
    'misidentification'
  end

  def self.object_relationship_name
    'correct identification'
  end


  def self.assignment_method
    # aus.iczn_misidentification = bus
    :iczn_misidentification
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_iczn_misidentification_of(aus)
    :set_as_iczn_misidentification_of
  end
end