class TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentMonotypy < TaxonNameRelationship::Typification::Genus::Subsequent

  soft_validate(:sv_described_after_1930, set: :described_after_1930)

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Typification::Genus::Subsequent,
                          TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentDesignation,
                          TaxonNameRelationship::Typification::Genus::Subsequent::RulingByCommission)
  end

  def object_status
    'type of genus by subsequent monotypy'
  end

  def subject_status
    'type species by subsequent monotypy'
  end

  def self.assignment_method
    :type_of_genus_by_subsequent_monotypy
  end

  def self.inverse_assignment_method
    :type_species_by_subsequent_monotypy
  end

  def sv_described_after_1930
    o = object_taxon_name
    if o.year_of_publication && o.year_of_publication > 1930
      soft_validations.add(:type, "Genus #{o.cached_html_name_and_author_year} described after 1930 is nomen nudum, if type was not designated in the original publication")
    end
  end

  def sv_not_specific_relationship
    true
  end
end
