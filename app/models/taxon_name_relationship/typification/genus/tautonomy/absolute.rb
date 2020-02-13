class TaxonNameRelationship::Typification::Genus::Tautonomy::Absolute < TaxonNameRelationship::Typification::Genus::Tautonomy

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Typification::Genus::Tautonomy,
            TaxonNameRelationship::Typification::Genus::Tautonomy::Linnaean)
  end

  def object_status
    'type of genus by absolute tautonomy'
  end

  def subject_status
    'type species by absolute tautonomy'
  end

  def self.assignment_method
    :type_of_genus_by_absolute_tautonomy
  end

  def self.inverse_assignment_method
    :type_species_by_absolute_tautonomy
  end

  def sv_not_specific_relationship
    true
  end
end
