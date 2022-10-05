# An ObservationMatrixColumn defines the column in an observation matrix.
# ObservationMatrixColumn items are only created and destroyed through references to ObservationMatrixColumnItems, never directly!
#
#
# @!attribute observation_matrix_id
#   @return [Integer]
#     the observation matrix
#
# @!attribute descriptor_id
#   @return [Integer]
#     the descriptor in the column
#
# @!attribute reference_count
#   @return [Integer]
#     a count of how many times this descriptor is referenced from observation_matrix_column_items.  A column
#     can be present via individual reference, or via reference through dynamic column sets.
#
# @!attribute cached_observation_matrix_column_item_id 
#   @return [Integer]
#      if the reference_count is 1, and the presence of this column is here because of 
#      reference to a /Single/ ObservationMatrixColumnItem column, then cache the ID of that column  
#    
class ObservationMatrixColumn < ApplicationRecord
  include Housekeeping
  include Shared::Tags
  include Shared::Notes
  include Shared::IsData

  acts_as_list scope: [:observation_matrix_id, :project_id]

  belongs_to :observation_matrix, inverse_of: :observation_matrix_columns
  belongs_to :descriptor, inverse_of: :observation_matrix_columns

  after_initialize :set_reference_count

  validates_presence_of :observation_matrix, :descriptor
  validates_uniqueness_of :descriptor_id, scope: [:observation_matrix_id, :project_id]

  # @return Scope
  #  There is no order to these Observations!  They do not follow the row order.
  def observations
    Observation.in_observation_matrix(observation_matrix_id).where(descriptor_id: descriptor_id)
  end

  # @param array [Array]
  # @return true
  #   incrementally sort the supplied ids
  def self.sort(array)
    array.each_with_index do |id, index|
      ObservationMatrixColumn.where(id: id).update_all(position: index + 1) 
    end
    true
  end

  # TODO: belong in helpers
  def next_column
    observation_matrix.observation_matrix_columns.where("position > ?", position).order(:position).first
  end

  def previous_column
    observation_matrix.observation_matrix_columns.where("position < ?", position).order('position DESC').first
  end

  protected

  def set_reference_count
    reference_count ||= 0
  end

end
