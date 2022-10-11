class TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary::Suppressed < TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000108'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary::Forgotten)
  end

  def object_status
    'conserved primary homonym'
  end

  def subject_status
    'suppressed primary homonym'
  end

  def self.assignment_method
    # bus.set_as_iczn_suppressed_homonym_of(aus)
    :iczn_set_as_suppressed_homonym_of
  end

  def self.inverse_assignment_method
    # aus.iczn_suppressed_homonym = bus
    :iczn_suppressed_homonym
  end

  def self.nomenclatural_priority
    :reverse
  end

  def sv_validate_priority
    date1 = self.subject_taxon_name.nomenclature_date
    date2 = self.object_taxon_name.nomenclature_date
    if !!date1 && !!date2 && date1 > date2 && subject_invalid_statuses.empty?
      soft_validations.add(:type, "#{self.subject_status.capitalize} #{self.subject_taxon_name.cached_html_name_and_author_year} should not be younger than #{self.object_taxon_name.cached_html_name_and_author_year}")
    end
  end

  def sv_synonym_relationship
    unless self.source
      soft_validations.add(:base, 'The original publication is not selected')
    end
  end
end