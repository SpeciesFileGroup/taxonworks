class TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentDesignation < TaxonNameRelationship::Typification::Genus::Subsequent

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Typification::Genus::Subsequent,
                          TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentMonotypy,
                          TaxonNameRelationship::Typification::Genus::Subsequent::RulingByCommission)
  end

  def object_status
    'type of genus by subsequent designation'
  end

  def subject_status
    'type species by subsequent designation'
  end

  def self.assignment_method
    :type_of_genus_by_subsequent_designation
  end

  def self.inverse_assignment_method
    :type_species_by_subsequent_designation
  end

end
