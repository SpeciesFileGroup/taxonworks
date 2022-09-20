class TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary < TaxonNameRelationship::Iczn::Invalidating::Homonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000291'.freeze

  soft_validate(:sv_same_original_genus, set: :specific_relationship)
  soft_validate(:sv_same_genus, set: :specific_relationship)
  soft_validate(:sv_combinations, set: :specific_relationship)

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
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Homonym,
            TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary)
  end

  def object_status
    'senior secondary homonym'
  end

  def subject_status
    'secondary homonym'
  end

  def self.assignment_method
    # bus.set_as_iczn_secondary_homonym_of(aus)
    :iczn_set_as_secondary_homonym_of
  end

  def self.inverse_assignment_method
    # aus.iczn_secondary_homonym = bus
    :iczn_secondary_homonym
  end

  def sv_same_original_genus
    s = subject_taxon_name
    o = object_taxon_name
    if !s.original_genus.nil? && s.original_genus == o.original_genus
      soft_validations.add(:type, "#{s.cached_html_name_and_author_year} and #{o.cached_html_name_and_author_year} species described in the same original genus #{s.original_genus}, they are primary homonyms")
    end
  end

  def sv_same_genus
    s = subject_taxon_name
    o = object_taxon_name
    if s.get_valid_taxon_name.ancestor_at_rank('genus') != o.get_valid_taxon_name.ancestor_at_rank('genus')
      soft_validations.add(:type, "Secondary homonyms #{s.cached_html_name_and_author_year} and #{o.cached_html_name_and_author_year} should be placed in the same parent genus, the homonymy should be deleted or changed to 'secondary homonym replaced before 1961'")
    end
  end

  def sv_specific_relationship
    s = subject_taxon_name
    o = object_taxon_name
    if s.cached_secondary_homonym_alternative_spelling != o.cached_secondary_homonym_alternative_spelling
      soft_validations.add(:type, "#{s.cached_html_name_and_author_year} and #{o.cached_html_name_and_author_year} are not similar enough to be homonyms")
    end
  end

  def sv_combinations
    s = subject_taxon_name
    o = object_taxon_name
    if (s.all_generic_placements & o.all_generic_placements).empty?
      soft_validations.add(:base, "No combination available showing #{s.cached_html_name_and_author_year} and #{o.cached_html_name_and_author_year} placed in the same genus")
    end
  end

  def sv_not_specific_relationship
    true
  end

  def sv_synonym_relationship
    unless self.source
      soft_validations.add(:base, 'The original publication is not selected')
    end
  end

end
