class TaxonNameRelationship::Typification::Genus::Monotypy::Subsequent < TaxonNameRelationship::Typification::Genus::Monotypy

  def self.assignment_method
    :type_species_by_subsequent_monotypy 
  end

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Typification::Genus::Monotypy.to_s] +
        [TaxonNameRelationship::Typification::Genus::Monotypy::Original.to_s]
  end


end
