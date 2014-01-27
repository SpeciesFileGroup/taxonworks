class TaxonNameRelationship::Typification::Genus::Monotypy::Subsequent < TaxonNameRelationship::Typification::Genus::Monotypy

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Typification::Genus::Monotypy,
            TaxonNameRelationship::Typification::Genus::Monotypy::Original)
  end

  def self.subject_relationship_name
    'type of genus by subsequent monotypy'
  end

  def self.object_relationship_name
    'type species by subsequent monotypy'
  end

  def self.assignment_method
    :type_of_genus_by_subsequent_monotypy
  end

  def self.inverse_assignment_method
    :type_species_by_subsequent_monotypy
  end

end
