class TaxonNameRelationship::Typification::Genus::Original < TaxonNameRelationship::Typification::Genus

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Typification::Genus::Subsequent,
                                                 TaxonNameRelationship::Typification::Genus::Tautonomy,) +
        self.collect_to_s(TaxonNameRelationship::Typification::Genus)
  end

  def object_status
    'type of genus by original designation or monotypy'
  end

  def subject_status
    'type species by original designation or monotypy'
  end

  def self.assignment_method
    :type_of_genus_by_original_designation_or_monotypy
  end

  def self.inverse_assignment_method
    :type_species_by_original_designation_or_monotypy
  end

  def sv_not_specific_relationship
    soft_validations.add(:type, 'Please specify if this is Original Designation or Original Monotypy')
  end

  def sv_validate_priority
    unless self.type_class.nomenclatural_priority.nil?
      date1 = self.subject_taxon_name.nomenclature_date
      date2 = self.object_taxon_name.nomenclature_date
      if !!date1 && !!date2 && date1 > date2 && subject_invalid_statuses.empty?
        soft_validations.add(:subject_taxon_name_id, "#{self.subject_status.capitalize} #{self.subject_taxon_name.cached_html_name_and_author_year} should not be younger than #{self.object_taxon_name.cached_html_name_and_author_year}")
      end
    end
  end

end
