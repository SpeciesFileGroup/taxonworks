# The class relationships used to indication current combination for plant names
class TaxonNameRelationship::CurrentCombination < TaxonNameRelationship

  validates_uniqueness_of :object_taxon_name_id, scope: :type
  validate :subject_is_combination
  validate :object_is_protonym

  soft_validate(
    :sv_classification_matches_current_combination,
    set: :classification_matches_current_combination,
    name: 'Classification matches current combination',
    description: 'Detect if the parent of the protonym matches the current combination' )

  has_one :related_taxon_name_relationship, class_name: 'TaxonNameRelationship::CurrentCombination',
           foreign_key: :object_taxon_name_id,
           inverse_of: :object_taxon_name

  # @return String
  #    the status inferred by the relationship to the object name
  def object_status
    'has current combination '
  end

  # @return String
  #    the status inferred by the relationship to the subject name
  def subject_status
    'current combination '
  end

  # @return String
  def subject_status_connector_to_object
    ''
  end

  # @return String
  def object_status_connector_to_subject
    ' of'
  end

  # right_side
  def self.valid_object_ranks
    GENUS_AND_SPECIES_RANK_NAMES_ICN
  end

  def self.assignable
    true
  end

  def self.assignment_method
    :combination_in_current_combination
  end

  # as.
  def self.inverse_assignment_method
    :protonym_in_current_combination
  end

  protected

  def set_cached_names_for_taxon_names
    begin
      TaxonName.transaction do
        t = object_taxon_name
        t.update_columns(
          cached_author_year: t.get_author_and_year,
          cached_nomenclature_date: t.nomenclature_date)
      end
    end
    true
  end

  def subject_is_combination
    errors.add(:subject_taxon_name, 'Must be a combination') unless subject_taxon_name.type == 'Combination'
  end

  def object_is_protonym
    errors.add(:object_taxon_name, 'Must be a protonym') if object_taxon_name.type == 'Combination'
  end

  def sv_coordinated_taxa_object
    true # not applicable
  end

  def sv_validate_required_relationships
    true # not applicable
  end

  def sv_classification_matches_current_combination
    c = subject_taxon_name.protonyms_by_rank
    return true if c.empty? || c.count == 1
    t1 = c[c.keys[-2]]

    if object_taxon_name.parent_id != t1.id
      soft_validations.add(:object_taxon_name_id, "Current combination #{subject_taxon_name.cached} is conflicting with the parent of protonym '#{object_taxon_name.cached}'")
    end
  end
end