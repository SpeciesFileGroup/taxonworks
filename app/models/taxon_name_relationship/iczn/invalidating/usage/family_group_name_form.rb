class TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm < TaxonNameRelationship::Iczn::Invalidating::Usage
  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000061'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_to_s(TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling,
                                      TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameOriginalForm,
                                      TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling)
  end

  def subject_properties
    []
  end

  def subject_status
    'family-group name form'
  end

  def self.gbif_status_of_subject
    'nullum'
  end

  def self.assignment_method
    # bus.set_as_misspelling_of(aus)
    :iczn_set_as_family_group_name_form_of
  end

  def self.inverse_assignment_method
    # aus.misspelling = bus
    :iczn_family_group_name_form
  end

  def self.assignable
    true
  end

end