class TaxonNameRelationship::Iczn::Invalidating::Synonym < TaxonNameRelationship::Iczn::Invalidating

  validate :validate_uniqueness_of_subject

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Invalidating::Usage.descendants.collect{|t| t.to_s} +
        TaxonNameRelationship::Iczn::Invalidating::Homonym.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Iczn::Invalidating::Homonym.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating.to_s]
  end

  def self.assignment_method
         # aus.iczn_synonym = bus
    :iczn_synonym
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_iczn_synonym_of(aus)
    :set_as_iczn_synonym_of
  end

  def validate_uniqueness_of_subject
    if TaxonNameRelationship.not_self.with_type_base(self.type.to_s).where(subject_taxon_name_id: self.subject_taxon_name_id).count > 0
      errors.add(:base, "Only one synonym relationship is allowed")
    end
  end

end