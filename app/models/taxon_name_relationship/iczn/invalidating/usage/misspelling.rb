class TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling < TaxonNameRelationship::Iczn::Invalidating::Usage

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000275'.freeze

  soft_validate(:sv_no_citation, set: :no_citation, has_fix: true)


  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_to_s(TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm,
                                      TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameOriginalForm,
                                      TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling)
  end

  def object_status
    'correct spelling'
  end

  def subject_status
    'misspelling'
  end

  def self.gbif_status_of_subject
    'nullum'
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

  protected

  def sv_no_citation
    if self.citations.empty?
      soft_validations.add(:base, "Citation for misspelling is not provided", fix: :sv_fix_no_citation, success_message: 'Citation is added')
    end
  end

  def sv_fix_no_citation
    c  = self.subject_taxon_name.origin_citation
    return false if c.nil?
    self.citations.create(source_id: c.source_id, pages: c.pages, is_original: true)
  end
end
