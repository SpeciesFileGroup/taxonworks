class TaxonNameRelationship::Icn::Accepting::SanctionedName < TaxonNameRelationship::Icn::Accepting

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000035'.freeze

  def self.assignable
    true
  end

  def object_status
    'rejected'
  end

  def subject_status
    'sanctioned'
  end

  def self.gbif_status_of_subject
    'conservandum'
  end

  def self.gbif_status_of_object
    'rejiciendum'
  end

  def self.nomenclatural_priority
    :reverse
  end

  def self.assignment_method
    # bus.set_as_icn_sanctioned_name_of(aus)
    :icn_set_as_sanctioned_name_of
  end

  def self.inverse_assignment_method
    # aus.icn_sanctioned_name = bus
    :icn_sanctioned_name
  end

  def sv_validate_priority
    date1 = self.subject_taxon_name.cached_nomenclature_date
    date2 = self.object_taxon_name.cached_nomenclature_date
    if !!date1 && !!date2 && date1 > date2 && subject_invalid_statuses.empty?
      soft_validations.add(:type, "#{self.subject_status.capitalize} #{self.subject_taxon_name.cached_html_name_and_author_year} should not be younger than #{self.object_taxon_name.cached_html_name_and_author_year}")
    end
  end
end
