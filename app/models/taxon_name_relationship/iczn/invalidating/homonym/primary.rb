class TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary < TaxonNameRelationship::Iczn::Invalidating::Homonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000290'.freeze

  soft_validate(:sv_same_original_genus, set: :specific_relationship)

  # left_side
  def self.valid_subject_ranks
    SPECIES_RANK_NAMES_ICZN
  end

  # right_side
  def self.valid_object_ranks
    SPECIES_RANK_NAMES_ICZN
  end

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Homonym)
  end

  def object_status
    'senior primary homonym'
  end

  def subject_status
    'primary homonym'
  end

  def self.assignment_method
    # bus.set_as_iczn_primary_homonym_of(aus)
    :iczn_set_as_primary_homonym_of
  end

  def self.inverse_assignment_method
    # aus.iczn_primary_homonym = bus
    :iczn_primary_homonym
  end

  def sv_specific_relationship
    s = subject_taxon_name
    o = object_taxon_name
    if s.cached_primary_homonym_alternative_spelling != o.cached_primary_homonym_alternative_spelling
      soft_validations.add(:type, "#{s.cached_html_name_and_author_year} and #{o.cached_html_name_and_author_year} are not similar enough to be homonyms")
    end
  end

  def sv_same_original_genus
    s = subject_taxon_name
    o = object_taxon_name
    if s.original_genus != o.original_genus
      soft_validations.add(:type, "Primary homonyms #{s.cached_html_name_and_author_year} and #{o.cached_html_name_and_author_year} should have the same original genus")
    end
  end

  def sv_not_specific_relationship
    true
  end

  def sv_synonym_relationship
    true
  end

end
