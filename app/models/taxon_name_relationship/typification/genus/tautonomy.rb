class TaxonNameRelationship::Typification::Genus::Tautonomy < TaxonNameRelationship::Typification::Genus
  def self.assignment_method
    :type_species_by_tautonomy
  end

  def self.assignable
    true
  end

end
