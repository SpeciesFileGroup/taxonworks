class TaxonNameRelationship::Typification::Genus::Monotypy::Original < TaxonNameRelationship::Typification::Genus::Monotypy

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships + self.collect_to_s(
        TaxonNameRelationship::Typification::Genus::Monotypy,
        TaxonNameRelationship::Typification::Genus::Monotypy::Subsequent)
  end

  def self.subject_relationship_name
    'type species by original monotypy'
  end

  def self.assignment_method
    :type_species_by_original_monotypy
  end

end
