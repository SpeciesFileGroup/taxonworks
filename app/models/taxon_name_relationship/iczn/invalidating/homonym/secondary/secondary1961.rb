class TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary::Secondary1961 <  TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000292'.freeze

  soft_validate(:sv_year_of_description, set: :specific_relationship)
  soft_validate(:sv_source_not_selected, set: :specific_relationship)
  soft_validate(:sv_source_after_1960, set: :specific_relationship)


  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary.to_s]
  end

  def object_status
    'senior secondary homonym'
  end

  def subject_status
    'secondary homonym replaced before 1961'
  end

  def self.assignment_method
    # bus.set_as_iczn_secondary_homonym_before_1961_of(aus)
    :iczn_set_as_secondary_homonym_before_1961_of
  end

  def self.inverse_assignment_method
    # aus.iczn_secondary_homonym_before_1961 = bus
    :iczn_secondary_homonym_before_1961
  end

  def sv_year_of_description
    s = subject_taxon_name
    soft_validations.add(:type, "#{s.cached_html_name_and_author_year} was not described before 1961") if s.year_of_publication && s.year_of_publication > 1960
  end

  def sv_source_not_selected
    soft_validations.add(:base, 'The original publication is not selected') unless source
  end

  def sv_source_after_1960
    if self.source
      s = subject_taxon_name
      soft_validations.add(:base, "#{s.cached_html_name_and_author_year} should not be treated as a homonym established before 1961") if self.source.year > 1960
    end
  end

  def sv_same_genus
    true
  end

  def sv_specific_relationship
    true
  end

  def sv_not_specific_relationship
    true
  end

end
