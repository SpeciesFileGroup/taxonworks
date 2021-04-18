class TaxonNameRelationship::Iczn::PotentiallyValidating::FamilyBefore1961 < TaxonNameRelationship::Iczn::PotentiallyValidating

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000042'.freeze

  soft_validate(:sv_year_of_description, set: :specific_relationship, has_fix: false)
  soft_validate(:sv_source_after_1960, set: :specific_relationship, has_fix: false)

  # left_side
  def self.valid_subject_ranks
    FAMILY_RANK_NAMES_ICZN
  end

  # right_side
  def self.valid_object_ranks
    FAMILY_RANK_NAMES_ICZN
  end

  def object_status
    'family name based on genus synonym replaced before 1961'
  end

  def subject_status
    'validated as replacement for family-group name based on genus synonym before 1961'
  end

  def self.nomenclatural_priority
    :direct
  end

  def self.assignment_method
    # bus.set_as_iczn_family_before_1961_of(aus)
    :iczn_set_as_family_before_1961_of
  end

  # as.
  def self.inverse_assignment_method
    # Aidae.iczn_family_before_1961 = Bidae
    :iczn_family_before_1961
  end

  def self.assignable
    true
  end

  def sv_year_of_description
    s = subject_taxon_name
    soft_validations.add(:type, "#{s.cached_html_name_and_author_year} was not described before 1961") if s.year_of_publication && s.year_of_publication > 1960
  end

  def sv_source_after_1960
    if self.source
      s = subject_taxon_name
      soft_validations.add(:base, "#{s.cached_html_name_and_author_year} should be accepted as a replacement name before 1961") if self.source.year > 1960
    end
  end
end