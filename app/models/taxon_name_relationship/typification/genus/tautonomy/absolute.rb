class TaxonNameRelationship::Typification::Genus::Tautonomy::Absolute < TaxonNameRelationship::Typification::Genus::Tautonomy

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Typification::Genus::Tautonomy.to_s] +
        [TaxonNameRelationship::Typification::Genus::Tautonomy::Linnaean.to_s]
  end

  def self.assignment_method
    :type_species_by_absolute_tautonomy
  end

end
