# The class relationships used to indication current combination for plant names
class TaxonNameRelationship::CurrentCombination < TaxonNameRelationship

  validates_uniqueness_of :object_taxon_name_id, scope: :type
  validate :subject_is_combination
  validate :object_is_protonym

  has_one :related_taxon_name_relationship, class_name: 'TaxonNameRelationship',
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

  def self.assignment_method
    # bus.set_as_species_in_original_combination(aus)
    :current_combination
  end

  def self.inverse_assignment_method
    # aus.original_combination_form = bus
    :taxon_for_current_combination
  end

  def self.assignable
    true
  end

  protected

  def subject_is_combination
    errors.add(:subject_taxon_name, 'Must be a combination') unless subject_taxon_name.type == 'Combination'
  end

  def object_is_protonym
    errors.add(:object_taxon_name, 'Must be a protonym') if object_taxon_name.type == 'Combination'
  end

  def sv_coordinated_taxa_object
    true # not applicable
  end
end