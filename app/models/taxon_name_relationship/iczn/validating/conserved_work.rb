class TaxonNameRelationship::Iczn::Validating::ConservedWork < TaxonNameRelationship::Iczn::Validating

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000023'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Iczn::Validating::UncertainPlacement,
            TaxonNameRelationship::Iczn::Validating::ConservedName)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Unavailable,
                                                 TaxonNameClassification::Iczn::Available::Valid::NomenDubium)
  end


  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Available::Valid) +
        self.collect_to_s(TaxonNameClassification::Iczn::Available::OfficialListOfFamilyGroupNamesInZoology,
                          TaxonNameClassification::Iczn::Available::OfficialListOfGenericNamesInZoology,
                          TaxonNameClassification::Iczn::Available::OfficialListOfWorksApprovedAsAvailable,
                          TaxonNameClassification::Iczn::Available::Invalid)

  end

  def self.assignable
    true
  end

  def self.nomenclatural_priority
    :reverse
  end

  def object_status
    'suppressed work'
  end

  def subject_status
    'conserved work'
  end

  def self.gbif_status_of_subject
    'conservandum'
  end

  def self.gbif_status_of_object
    'rejiciendum'
  end

  def self.assignable
    true
  end

  # as.
  def self.assignment_method
    # bus.set_as_conserved_name_of(aus)
    :iczn_set_as_conserved_work_of
  end

  def self.inverse_assignment_method
    # aus.iczn_conserved_name = bus
    :iczn_conserved_work
  end

  def sv_validate_priority
    date1 = self.subject_taxon_name.nomenclature_date
    date2 = self.object_taxon_name.nomenclature_date
    if !!date1 && !!date2 && date1 > date2 && subject_invalid_statuses.empty?
      soft_validations.add(:type, "#{self.subject_status.capitalize} #{self.subject_taxon_name.cached_html_name_and_author_year} should not be younger than #{self.object_taxon_name.cached_html_name_and_author_year}")
    end
  end
end