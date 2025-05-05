class TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression < TaxonNameRelationship::Iczn::Invalidating::Synonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000280'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName)
  end

  def subject_properties
    [ TaxonNameClassification::Iczn::Unavailable::Suppressed ]
  end

  def object_status
    'conserved'
  end

  def subject_status
    'suppressed'
  end

  def subject_status_connector_to_object
    ' under'
  end

  def object_status_connector_to_subject
    ' for'
  end


  def self.gbif_status_of_subject
    'rejiciendum'
  end

  def self.gbif_status_of_object
    'conservandum'
  end

  def self.nomenclatural_priority
    :reverse
  end

  def self.assignment_method
    # bus.set_as_iczn_suppression_of(aus)
    :iczn_set_as_suppression_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.iczn_suppression = bus
    :iczn_suppression
  end

  def sv_not_specific_relationship
    soft_validations.add(:type, 'Please specify if this is a total, partial, or conditional suppression')
  end

  def sv_validate_priority
    date1 = self.subject_taxon_name.cached_nomenclature_date
    date2 = self.object_taxon_name.cached_nomenclature_date
    if !!date1 && !!date2 && date1 > date2 && subject_invalid_statuses.empty?
      soft_validations.add(:type, "#{self.subject_status.capitalize} #{self.subject_taxon_name.cached_html_name_and_author_year} should not be younger than #{self.object_taxon_name.cached_html_name_and_author_year}")
    end
  end
end
