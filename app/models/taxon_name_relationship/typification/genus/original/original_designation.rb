class TaxonNameRelationship::Typification::Genus::Original::OriginalDesignation < TaxonNameRelationship::Typification::Genus::Original

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Typification::Genus::Original,
            TaxonNameRelationship::Typification::Genus::Original::OriginalMonotypy)
  end

  def object_status
    'type of genus by original designation'
  end

  def subject_status
    'type species by original designation'
  end

  def self.assignment_method
    :type_of_genus_by_original_designation
  end

  def self.inverse_assignment_method
    :type_species_by_original_designation
  end

  def sv_not_specific_relationship
    true
  end
end
