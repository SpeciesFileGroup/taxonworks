class TaxonNameRelationship::Typification::Genus < TaxonNameRelationship::Typification

  def self.assignment_method
    :type_species
  end

end
