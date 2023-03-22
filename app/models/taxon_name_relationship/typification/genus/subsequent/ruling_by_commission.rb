class TaxonNameRelationship::Typification::Genus::Subsequent::RulingByCommission < TaxonNameRelationship::Typification::Genus::Subsequent

  def self.disjoint_taxon_name_relationships
  self.parent.disjoint_taxon_name_relationships +
      self.collect_to_s(TaxonNameRelationship::Typification::Genus::Subsequent,
                        TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentMonotypy,
                        TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentDesignation)
end

  def object_status
    'type of genus by ruling by the Commission'
  end

  def subject_status
    'type species by ruling by the Commission'
  end

  def self.assignment_method
    :type_of_genus_by_ruling_by_commission
  end

  def self.inverse_assignment_method
    :type_species_by_ruling_by_commission
  end

    def self.nomenclatural_priority
      nil
    end

  def sv_not_specific_relationship
    true
  end
end
