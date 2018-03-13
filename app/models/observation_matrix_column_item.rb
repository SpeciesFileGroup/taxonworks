#
# Each ObservationMatrixColumnItem is set of descriptors
#
class ObservationMatrixColumnItem < ApplicationRecord
  include Housekeeping
  include Shared::Identifiers
  include Shared::IsData
  include Shared::Notes
  include Shared::Tags

  acts_as_list scope: [:observation_matrix_id, :project_id]

  ALL_STI_ATTRIBUTES = [:descriptor_id, :controlled_vocabulary_term_id].freeze

  belongs_to :observation_matrix, inverse_of: :observation_matrix_column_items

  # TODO: remove from subclasses
  belongs_to :descriptor, inverse_of: :observation_matrix_column_items
  belongs_to :controlled_vocabulary_term

  #  belongs_to :controlled_vocabulary_term (belongs elsewhere)

  validates_presence_of :observation_matrix
  validate :type_is_subclassed
  validate :other_subclass_attributes_not_set

  after_save :update_matrix_columns
  after_destroy :cleanup_matrix_columns

  def cleanup_matrix_columns
    ObservationMatrixColumn.where(descriptor_id: descriptors.map(&:id), observation_matrix: observation_matrix).each do |mc|
      cleanup_single_matrix_column mc.descriptor_id, mc
    end
    true
  end

  def update_matrix_columns
    descriptors.each do |d|
      update_single_matrix_column d
    end
  end

  def cleanup_single_matrix_column(descriptor_id, mc = nil)
    mc ||= ObservationMatrixColumn.where(
      descriptor_id: descriptor_id, 
      observation_matrix: observation_matrix).first

    current = mc.reference_count - 1
    if current == 0
      mc.delete
    else
      mc.update_columns(reference_count: current)
    end
  end

  def update_single_matrix_column(descriptor)
    mc = ObservationMatrixColumn.find_or_create_by(
      observation_matrix: observation_matrix, descriptor: descriptor)
    mc.update_columns(reference_count: mc.reference_count + 1)
  end

  def self.human_name
    self.name.demodulize.humanize
  end

  # @return [Array]
  #    the required attributes for this subclass
  # override
  def self.subclass_attributes
    []
  end

  # @return [Array]
  #    the descriptors "defined" by this matrix column item
  # override
  def descriptors
    false
  end

  protected

  def other_subclass_attributes_not_set
    (ALL_STI_ATTRIBUTES - self.class.subclass_attributes).each do |atr|
      errors.add(atr, 'is not valid for this type of observation matrix column item') if !send(atr).blank?
    end
  end

  def type_is_subclassed
    if !MATRIX_COLUMN_ITEM_TYPES[type]
      errors.add(:type, 'type must be a valid subclass')
    end
  end

end

Dir[Rails.root.to_s + '/app/models/observation_matrix_column_item/**/*.rb'].each { |file| require_dependency file }
