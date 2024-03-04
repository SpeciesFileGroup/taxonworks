class TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling < TaxonNameRelationship::Iczn::Invalidating::Usage

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000044'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_to_s(TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm,
                                      TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameOriginalForm,
                                      TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling)
  end

  def object_status
    'correct spelling'
  end

  def subject_status
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

  protected

  def sv_specific_relationship
    s = self.subject_taxon_name
    o = self.object_taxon_name
    if !s.cached_original_combination.blank? && s.cached_original_combination == o.cached_original_combination
      soft_validations.add(:base, "Incorrect and correctly spelled names are identical: '#{s.cached_original_combination}'")
    end
  end
end
