class TaxonNameRelationship::Typification::Genus::Tautonomy::Linnaean < TaxonNameRelationship::Typification::Genus::Tautonomy

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Typification::Genus::Tautonomy.to_s] +
        [TaxonNameRelationship::Typification::Genus::Tautonomy::Absolute.to_s]
  end

  def self.assignment_method
    :type_species_by_linnaean_tautonomy
  end

end
