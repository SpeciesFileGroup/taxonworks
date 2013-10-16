class TaxonNameRelationship::Typification::Genus::Tautonomy < TaxonNameRelationship::Typification::Genus
  def self.assignment_method
    :type_genus_by_tautonomy
  end
end
