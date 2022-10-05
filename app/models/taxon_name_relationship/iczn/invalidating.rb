class TaxonNameRelationship::Iczn::Invalidating < TaxonNameRelationship::Iczn

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000272'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Validating)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_descendants_to_s(TaxonNameClassification::Iczn::Available::Valid) +
        self.collect_to_s(TaxonNameClassification::Iczn::Available)
  end

  def self.nomenclatural_priority
    :direct
  end

  def self.assignable
    true
  end

  def subject_properties
    [ TaxonNameClassification::Iczn::Available::Invalid ]
  end


  def subject_status
    'unavailable or invalid'
  end

  def object_status
    'valid'
  end

  def subject_status_connector_to_object
    ', linked to'
  end

  def object_status_connector_to_subject
    ' for'
  end


  def self.gbif_status_of_subject
    'invalidum'
  end


  # as.
  def self.assignment_method
    # bus.set_as_iczn_invalid_of(aus)
    :iczn_set_as_invalid_of
  end

  def self.inverse_assignment_method
    # aus.iczn_invalid = bus   ## Equal to synonym in broad sense
    :iczn_invalid
  end

  # @return [Boolean]
  #   See use in Protonym.becomes_combination. It does not make sense to run this on all relationships.
  def similar_homonym_string
    a = subject_taxon_name
    b = object_taxon_name
    if a.is_species_rank? && a.cached_secondary_homonym_alternative_spelling.nil? && a.cached_valid_taxon_name_id == b.cached_valid_taxon_name_id
      return true if a.name == b.name
    elsif a.is_species_rank?
      return true if a.cached_secondary_homonym_alternative_spelling && (a.cached_secondary_homonym_alternative_spelling == b.cached_secondary_homonym_alternative_spelling)
    elsif a.is_genus_rank?
      return true if a.cached_primary_homonym_alternative_spelling && (a.cached_primary_homonym_alternative_spelling == b.cached_primary_homonym_alternative_spelling)
    else
      return false
    end
    false
  end

  def sv_not_specific_relationship
    if self.subject_taxon_name.is_available?
      soft_validations.add(:type, 'Please specify the reason for the name being Invalid')
    end
  end

  def sv_synonym_relationship
    unless self.source
      soft_validations.add(:base, 'The original publication is not selected')
    end
  end
end
