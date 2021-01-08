class TaxonNameRelationship::Iczn::PotentiallyValidating::ReplacementName < TaxonNameRelationship::Iczn::PotentiallyValidating

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000270'.freeze

  def self.assignable
    true
  end

  def object_status
    'replaced with'
  end

  def subject_status
    'nomen novum'
  end

  def self.gbif_status_of_subject
    'novum'
  end

  # as.
  def self.assignment_method
    # bus.set_as_replacement_name_of(aus)
    :iczn_set_as_replacement_name_of
  end

  def self.inverse_assignment_method
    # aus.iczn_replacement_name = bus
    :iczn_replacement_name
  end

  def self.nomenclatural_priority
    :direct
  end

  def sv_specific_relationship
    s = subject_taxon_name
    o = object_taxon_name
    r1 = TaxonNameRelationship.where(type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::ReplacedHomonym', subject_taxon_name_id: o.id, object_taxon_name_id: s.id).first
    r2 = TaxonNameRelationship.where(type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName', subject_taxon_name_id: s.id, object_taxon_name_id: o.id).first
    soft_validations.add(:base, "Missing relationship: #{s.cached_html_name_and_author_year} is a replacement name for #{o.cached_html_name_and_author_year}. Please add an objective synonym relationship (either 'replaced homonym' or 'unnecessary replacement name')") if r1.nil? && r2.nil?
  end
end
