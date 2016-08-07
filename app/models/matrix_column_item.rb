
# Each MatrixColumnItem is set of descriptors
#
class MatrixColumnItem < ActiveRecord::Base
  include Housekeeping
  include Shared::Identifiable
  include Shared::IsData
  include Shared::Notable
  include Shared::Taggable

  ALL_STI_ATTRIBUTES = [:descriptor_id, :controlled_vocabulary_term_id]

  belongs_to :matrix

  #  belongs_to :controlled_vocabulary_term (belongs elsewhere) 

  validates_presence_of :matrix_id
  validate :type_is_subclassed
  validate :other_subclass_attributes_not_set

  after_save :update_matrix_columns
  after_destroy :cleanup_matrix_columns

  def cleanup_matrix_columns
    MatrixColumn.where(descriptor_id: descriptors.map(&:id), matrix: matrix).each do |mc|
      current = mc.reference_count - 1 
      if current == 0
        mc.delete
      else
        mc.update_columns(reference_count: current)
      end
    end
    true
  end

  def update_matrix_columns
    descriptors.each do |d|
      mc = MatrixColumn.find_or_create_by(matrix: matrix, descriptor: d)
      mc.update_columns(reference_count: mc.reference_count + 1)
    end
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
      errors.add(atr, 'is not valid for this type of matrix column item') if !send(atr).blank?
    end
  end

  def type_is_subclassed
    if !MATRIX_COLUMN_ITEM_TYPES[type]
      errors.add(:type, 'type must be a valid subclass')
    end
  end

end

Dir[Rails.root.to_s + '/app/models/matrix_column_item/**/*.rb'].each { |file| require_dependency file }
