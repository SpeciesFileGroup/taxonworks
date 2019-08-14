class TaxonNameRelationship::Typification::Genus::Original::OriginalMonotypy < TaxonNameRelationship::Typification::Genus::Original

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Typification::Genus::Original,
                          TaxonNameRelationship::Typification::Genus::Original::OriginalDesignation)
  end

  def object_status
    'type of genus by original monotypy'
  end

  def subject_status
    'type species by original monotypy'
  end

  def self.assignment_method
    :type_of_genus_by_original_monotypy
  end

  def self.inverse_assignment_method
    :type_species_by_original_monotypy
  end

  def sv_specific_relationship
    # @todo Check if more than one species associated with the genus in the original paper
  end

  def sv_not_specific_relationship
    true
  end
end


