class TaxonNameRelationship::Typification::Genus::Subsequent < TaxonNameRelationship::Typification::Genus

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Typification::Genus::Original,
                                                 TaxonNameRelationship::Typification::Genus::Tautonomy,) +
        self.collect_to_s(TaxonNameRelationship::Typification::Genus)
  end

  def object_status
    'type of genus by subsequent designation or monotypy'
  end

  def subject_status
    'type species by subsequent designation or monotypy'
  end

  def self.assignment_method
    :type_of_genus_by_subsequent_designation_or_monotypy
  end

  def self.inverse_assignment_method
    :type_species_by_subsequent_designation_or_monotypy
  end

  protected

  def sv_synonym_relationship
    if self.source
      date1 = self.source.cached_nomenclature_date.to_time
      date2 = self.subject_taxon_name.nomenclature_date
      if !!date1 && !!date2
        soft_validations.add(:base, "#{self.subject_taxon_name.cached_html_name_and_author_year} was not described at the time of citation (#{date1.to_date})") if date2.to_date > date1.to_date
      end
    else
      soft_validations.add(:base, 'The original publication is not selected')
    end
  end

  def sv_not_specific_relationship
    soft_validations.add(:type, 'Please specify if this is Subsequent Designation or Subsequent Monotypy')
  end

  def sv_validate_priority
    unless self.type_class.nomenclatural_priority.nil?
      date1 = self.subject_taxon_name.nomenclature_date
      date2 = self.object_taxon_name.nomenclature_date
      if !!date1 && !!date2 && date1 > date2 && subject_invalid_statuses.empty? && date2 > '1930-12-31'.to_time
        soft_validations.add(:subject_taxon_name_id, "#{self.subject_status.capitalize} #{self.subject_taxon_name.cached_html_name_and_author_year} should not be younger than #{self.object_taxon_name.cached_html_name_and_author_year}")
      end
    end
  end
end
