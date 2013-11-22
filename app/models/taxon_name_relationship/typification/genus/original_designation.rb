class TaxonNameRelationship::Typification::Genus::OriginalDesignation < TaxonNameRelationship::Typification::Genus

  def self.assignment_method
    :type_species_by_original_designation 
  end

  def self.assignable
    true
  end

end
