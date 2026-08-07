class TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName::ForgottenName19611972 < TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0003011'.freeze

  soft_validate(:sv_source_between_1961_and_1972, set: :specific_relationship)

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName)
  end

  def object_status
    'nomen protectum'
  end

  def subject_status
    'nomen oblitum rejected between 6 November 1961 and 1 January 1973'
  end

  def self.gbif_status_of_subject
    'oblitum'
  end

  def self.nomenclatural_priority
    :reverse
  end

  def self.assignment_method
    # bus.set_as_iczn_forgotten_name_of(aus)
    :iczn_set_as_forgotten_name19611972_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.iczn_forgotten_name = bus
    :iczn_forgotten_name19611972
  end

  def sv_not_specific_relationship
    true
  end

  def sv_source_between_1961_and_1972
    s = subject_taxon_name
    d = self&.origin_citation&.source&.cached_nomenclature_date
    return true if d.nil?
    soft_validations.add(:type, "#{s.cached_html_name_and_author_year} was not rejected between 6 November 1961 and 1 January 1973") if d < Date.parse('1961-11-06') || d > Date.parse('1973-01-01')
  end

  def sv_validate_priority
    date1 = self.subject_taxon_name.cached_nomenclature_date
    date2 = self.object_taxon_name.cached_nomenclature_date
    if !!date1 && !!date2 && date1 > date2 && subject_invalid_statuses.empty?
      soft_validations.add(:type, "#{self.subject_status.capitalize} #{self.subject_taxon_name.cached_html_name_and_author_year} should not be younger than #{self.object_taxon_name.cached_html_name_and_author_year}")
    end
  end
end
