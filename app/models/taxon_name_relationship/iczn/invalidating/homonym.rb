class TaxonNameRelationship::Iczn::Invalidating::Homonym < TaxonNameRelationship::Iczn::Invalidating

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000289'.freeze

  soft_validate(
    :sv_validate_total_suppression,
    set: :validate_homonym_relationships,
    name: 'Validate total suppression',
    description: 'Taxon should not be treated as homonym, since the related taxon is totally suppressed.' )

  soft_validate(
    :sv_missing_nomen_novum,
    set: :validate_homonym_relationships,
    name: 'Substitute name is not selected',
    description: 'Please select a replacement or substitute name.' )

  soft_validate(
    :sv_missing_replacement_name,
    set: :validate_homonym_relationships,
    fix: :sv_fix_add_synonym_for_homonym,
    name: 'Missing replacement name',
    description: 'Please select a valid name using synonym relationships.' )

  #  soft_validate(:sv_not_specific_relationship,
  #              set: :not_specific_relationship,
  #              fix: :sv_fix_not_specific_relationship,
  #              name: 'Not specific homonym relationship',
  #              description: 'Check if homonymy could be defined as primary or secondary.' )

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_to_s(TaxonNameRelationship::Iczn::Invalidating::Usage) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Total)

  end

#  def self.disjoint_object_classes
#    self.parent.disjoint_object_classes
#  end

  def subject_properties
    [ TaxonNameClassification::Iczn::Available::Invalid::Homonym ]
  end

  def object_status
    'senior homonym'
  end

  def subject_status
    'homonym'
  end

  def subject_status_connector_to_object
    ' of'
  end

  def object_status_connector_to_subject
    ' of'
  end

  def self.assignment_method
    # bus.set_as_iczn_homonym_of(aus)
    :iczn_set_as_homonym_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.iczn_homonym = bus
    :iczn_homonym
  end

  def sv_validate_total_suppression
    if !self.object_taxon_name.iczn_set_as_total_suppression_of.nil?
      soft_validations.add(:type, 'Taxon should not be treated as homonym, since the related taxon is totally suppressed')
    end
  end

  def sv_missing_nomen_novum
    if self.subject_taxon_name.iczn_set_as_synonym_of.nil? && self.subject_taxon_name.iczn_replacement_names.empty?
      soft_validations.add(:type, 'Please select a replacement or substitute name')
    end
  end

  def sv_missing_replacement_name
    if self.subject_taxon_name.iczn_set_as_synonym_of.nil? && !self.subject_taxon_name.iczn_replacement_names.empty?
      soft_validations.add(:type, 'Please select a valid name using synonym relationships',
                           success_message: 'Synonym relationship was added')
    end
  end

  def sv_specific_relationship
    s = subject_taxon_name
    o = object_taxon_name
    if (s.cached_primary_homonym_alternative_spelling != o.cached_primary_homonym_alternative_spelling)
      if (s.cached_secondary_homonym_alternative_spelling.blank? && o.cached_secondary_homonym_alternative_spelling.blank?) || (s.cached_secondary_homonym_alternative_spelling != o.cached_secondary_homonym_alternative_spelling)
        soft_validations.add(:type, "#{subject_taxon_name.cached_html_name_and_author_year} and #{object_taxon_name.cached_html_name_and_author_year} are not similar enough to be homonyms")
      end
    end
  end

  def sv_not_specific_relationship
    if SPECIES_RANK_NAMES_ICZN.include?(self.subject_taxon_name.rank_string)
      soft_validations.add(
        :type, 'Please specify if this is a primary or secondary homonym',
        success_message: 'Homonym updated to being primary or secondary',
        failure_message:  'Failed to update the homonym relationship')
    end
  end

  def sv_fix_not_specific_relationship
    subject_original_genus = self.subject_taxon_name.original_genus
    object_original_genus = self.object_taxon_name.original_genus
    subject_genus = self.subject_taxon_name.ancestor_at_rank('genus')
    object_genus = self.object_taxon_name.ancestor_at_rank('genus')
    new_relationship_name = nil
    if subject_original_genus == object_original_genus && !subject_original_genus.nil?
      new_relationship_name = 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary'
    elsif subject_genus != object_genus && !subject_genus.nil?
      new_relationship_name = 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary'
    end
    if new_relationship_name && self.type_name != new_relationship_name
      self.update_columns(type: new_relationship_name)
      return true
    end
    false
  end

  def sv_validate_priority
    date1 = self.subject_taxon_name.nomenclature_date
    date2 = self.object_taxon_name.nomenclature_date
    if !!date1 && !!date2 && date2 > date1 && subject_invalid_statuses.empty?
      soft_validations.add(:type, "#{self.subject_status.capitalize} #{self.subject_taxon_name.cached_html_name_and_author_year} should not be older than #{self.object_status} #{self.object_taxon_name.cached_html_name_and_author_year}")
    end
  end

  def sv_fix_add_synonym_for_homonym
    if subject_taxon_name.iczn_set_as_synonym_of.nil?
      unless subject_taxon_name.iczn_replacement_names.empty?
        subject_taxon_name.iczn_set_as_synonym_of = object_taxon_name
        begin
          TaxonNameRelationship.transaction do
            self.save
            return true
          end
        rescue
        end
      end
    end
    false
  end

  def sv_synonym_relationship
    true
  end
end
