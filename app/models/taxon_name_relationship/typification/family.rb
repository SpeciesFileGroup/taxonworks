class TaxonNameRelationship::Typification::Family < TaxonNameRelationship::Typification

  soft_validate(:sv_matching_type_genus, set: :matching_type_genus)

  # left side
  def self.valid_subject_ranks
    GENUS_RANK_NAMES
  end

  # right_side
  def self.valid_object_ranks
    FAMILY_RANK_NAMES
  end

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Typification::Genus)
  end

  def object_status
    'type of family'
  end

  def subject_status
    'type genus'
  end

  def self.assignment_method
    :type_of_family
  end

  def self.inverse_assignment_method
    :type_genus
  end

  def self.assignable
    true
  end

  def sv_matching_type_genus
    if self.object_taxon_name.name.slice(0, 1) != self.subject_taxon_name.name.slice(0, 1)
      soft_validations.add(:object_taxon_name_id, "The type genus #{self.subject_taxon_name.cached_html_name_and_author_year} should have the same initial letters as the family-group name #{self.object_taxon_name.cached_html_name_and_author_year}")
    end
  end
end
