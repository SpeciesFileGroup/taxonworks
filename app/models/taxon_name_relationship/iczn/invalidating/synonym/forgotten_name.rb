class TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName < TaxonNameRelationship::Iczn::Invalidating::Synonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000284'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym)
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

  def sv_not_specific_relationship
    true
  end

  def sv_validate_priority
    date1 = self.subject_taxon_name.cached_nomenclature_date
    date2 = self.object_taxon_name.cached_nomenclature_date
    if !!date1 && !!date2 && date1 > date2 && subject_invalid_statuses.empty?
      soft_validations.add(:type, "#{self.subject_status.capitalize} #{self.subject_taxon_name.cached_html_name_and_author_year} should not be younger than #{self.object_taxon_name.cached_html_name_and_author_year}")
    end
  end
end
