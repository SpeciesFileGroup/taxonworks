# A ObservationMatrixRow is a row in an Observation matrix representing an Otu or a CollectionObject
#
# @!attribute observation_matrix_id
#   @return [Integer]
#     id of the matrix the row is in
#
# @!attribute observation_object_id
#   @return [Integer, nil]
#
# @!attribute observation_object_type
#   @return [String, nil]
#
# @!attribute reference_count
#   Indicates the total number of times this row is referened via some row_item
#   @return [Integer]
#
# @!attribute cached_observation_matrix_row_item_id
#   @return [Integer] if the column item is derived from a ::Single::<FOO> subclass, the id of that instance
#
# @!attribute name
#   @return [String, nil]
#     TEMPORARY value. Allows for a temporary generated/custom name for the row, useful for example when generating labels for phylogenetic trees.
#     This value is NOT persisted and NOT intended for provenance purposes, it is strictly utilitarian.  Consider using custom OTUs to track provenance.
#
# @!attribute position
#   @return [Integer] from acts as list
#
class ObservationMatrixRow < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Identifiers
  include Shared::Tags
  include Shared::Notes
  include SoftValidation
  include Shared::IsData

  include Shared::ObservationIndex

  acts_as_list scope: [:observation_matrix_id, :project_id]

  attr_accessor :observation_object_global_id

  belongs_to :observation_object, polymorphic: true
  belongs_to :observation_matrix, inverse_of: :observation_matrix_rows

  validates_presence_of :observation_matrix, :observation_object
  validate :observation_object_is_unique_in_matrix

  # This is strictly a sanity check, as these records
  # are not never created directly
  def observation_object_is_unique_in_matrix
    if ObservationMatrixRow.where(
        observation_matrix_id: observation_matrix_id,
        observation_object: observation_object).where.not(id: id).any?
      errors.add(:observation_object, 'already exists in this matrix')
    end
  end

  after_initialize :set_reference_count

  def observations
    observation_object.observations
      .joins(descriptor: [:observation_matrix_columns])
      .where(observation_matrix_columns: {observation_matrix_id: observation_matrix_id})
      .order('observation_matrix_columns.position ASC')
  end

  def observation_matrix_columns
    ObservationMatrixColumn.where(observation_matrix_id: observation_matrix_id)
  end

  soft_validate(
    :sv_cannot_be_separated,
    set: :cannot_be_separated,
    name: 'Cannot be separated',
    description: 'Observation matrix row cannot be separated from other rows in the matrix' )

  # @param array [Array]
  # @return true
  #   incrementally sort the supplied ids
  def self.sort(array)
    array.each_with_index do |id, index|
      ObservationMatrixRow.where(id: id).update_all(position: index + 1)
    end
    true
  end

  def set_reference_count
    self.reference_count ||= 0
  end

  def observation_object_global_id=(value)
    self.observation_object = GlobalID::Locator.locate(value)
    @observation_object_global_id = value
  end

  def current_taxon_name
    case observation_object_type
    when 'Otu'
      observation_object.taxon_name
    when 'CollectionObject'
      observation_object.current_taxon_name
    end
  end

  # TODO: A little bit suspect here, likely belongs in
  # helper or other lib context
  def current_otu
    case observation_object_type
    when 'Otu'
      observation_object
    when 'CollectionObject'
      observation_object.current_otu
    end
  end

  # TODO: belongs in helpers
  def next_row
    observation_matrix.observation_matrix_rows.where("position > ?", position).order(:position).first
  end

  def previous_row
    observation_matrix.observation_matrix_rows.where("position < ?", position).order('position DESC').first
  end

  private

  def sv_cannot_be_separated
    description = Tools::Description::FromObservationMatrix.new(observation_matrix_row_id: self.id)
    if description && description.generated_description.blank?
      soft_validations.add(:base, 'No observations!')
    elsif description && description.generated_diagnosis == 'Cannot be separated from other rows in the matrix!'
      str = description.generated_diagnosis.to_s + ' Similar rows:'
      s = description.similar_objects.first[:similarities]
      description.similar_objects.each do |i|
        break if i[:similarities] != s
        if i[:otu_id]
          str += ' ' + Otu.find(i[:otu_id]).otu_name + '.'
        else
          str += ' Collection object #' + i[:collection_object_id].to_s + '.'
        end
      end
      soft_validations.add(:base, str)
    end
  end
end
