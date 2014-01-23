class TaxonNameRelationship::Typification::Genus::Tautonomy::Linnaean < TaxonNameRelationship::Typification::Genus::Tautonomy

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Typification::Genus::Tautonomy,
            TaxonNameRelationship::Typification::Genus::Tautonomy::Absolute)
  end

  def self.subject_relationship_name
    'type species by Linnaean tautonomy'
  end

  def self.assignment_method
    :type_species_by_linnaean_tautonomy
  end

end
