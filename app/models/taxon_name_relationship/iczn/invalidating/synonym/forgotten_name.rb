class TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName < TaxonNameRelationship::Iczn::Invalidating::Synonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000284'.freeze

  soft_validate(:sv_source_after_1999, set: :specific_relationship)

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym,
                          TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName::ForgottenName19611972)
  end

  def object_status
    'nomen protectum'
  end

  def subject_status
    'nomen oblitum'
  end

  def self.gbif_status_of_subject
    'oblitum'
  end

  def self.nomenclatural_priority
    :reverse
  end

  def self.assignment_method
    # bus.set_as_iczn_forgotten_name_of(aus)
    :iczn_set_as_forgotten_name_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.iczn_forgotten_name = bus
    :iczn_forgotten_name
  end

  def sv_source_after_1999
    s = subject_taxon_name
    d = self&.origin_citation&.source&.cached_nomenclature_date
    return true if d.nil? || self.type != 'TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName'
    if d < Date.parse('2000-01-01')
      soft_validations.add(:type, "#{s.cached_html_name_and_author_year} was rejected before 2000")
    else
      o = object_taxon_name
      d1 = s&.origin_citation&.source&.cached_nomenclature_date
      d2 = o&.origin_citation&.source&.cached_nomenclature_date
      soft_validations.add(:subject_taxon_name_id, "#{s.cached_html_name_and_author_year} as <i>nomen oblitum</i> was not described before 1900") if d1 && d1 > Date.parse('1900-01-01')
      soft_validations.add(:object_taxon_name_id, "#{o.cached_html_name_and_author_year} as <i>nomen protectum</i> was not described before 1900") if d2 && d2 > Date.parse('1900-01-01')
    end
  end

  def sv_not_specific_relationship
    d = self&.origin_citation&.source&.cached_nomenclature_date
    return true if d.nil?
    if d >= Date.parse('1961-11-06') && d <= Date.parse('1973-01-01')
      soft_validations.add(
        :type, "The relationship should change to the 'Nomen oblitum rejected between 6 November 1961 and 1 January 1973'",
        success_message: "The relationship updated to 'Nomen oblitum rejected between 6 November 1961 and 1 January 1973'",
        failure_message:  'Failed to update the nomen oblitum relationship')
    end
  end

  def sv_fix_not_specific_relationship
    new_relationship_name = 'TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName::ForgottenName19611972'
    if new_relationship_name && self.type_name != new_relationship_name
      self.type = new_relationship_name
      self.save
      return true
    end
    false
  end

  def sv_validate_priority
    date1 = self.subject_taxon_name.cached_nomenclature_date
    date2 = self.object_taxon_name.cached_nomenclature_date
    if !!date1 && !!date2 && date1 > date2 && subject_invalid_statuses.empty?
      soft_validations.add(:type, "#{self.subject_status.capitalize} #{self.subject_taxon_name.cached_html_name_and_author_year} should not be younger than #{self.object_taxon_name.cached_html_name_and_author_year}")
    end
  end
end
