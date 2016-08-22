class MatrixRowItem < ActiveRecord::Base
  include Housekeeping
  include Shared::Citable
  include Shared::Identifiable
  include Shared::IsData
  include Shared::Taggable
  include Shared::Notable
  
  acts_as_list

  ALL_STI_ATTRIBUTES = [:otu_id, :collection_object_id, :controlled_vocabulary_term_id]

  belongs_to :matrix

  validates_presence_of :matrix_id
  validate :type_is_subclassed
  validate :other_subclass_attributes_not_set

  after_save :update_matrix_rows
  after_destroy :cleanup_matrix_rows

  def update_matrix_rows
    all_otus = otus
    all_collection_objects = collection_objects

    if all_otus
      all_otus.each do |o|
        mr = MatrixRow.find_or_create_by(matrix: matrix, otu: o)
        mr.update_columns(reference_count: mr.reference_count + 1)
      end
    end

    if all_collection_objects
      all_collection_objects.each do |co|
        mr = MatrixRow.find_or_create_by(matrix: matrix, collection_object: co)
        mr.update_columns(reference_count: mr.reference_count + 1)
      end
    end
  end

  def cleanup_matrix_rows
    all_otus = otus
    all_collection_objects = collection_objects
    
    rows = Array.new
    rows.push *MatrixRow.where(matrix: matrix, otu_id: all_otus.map(&:id)) if all_otus
    rows.push *MatrixRow.where(matrix: matrix, collection_object_id: all_collection_objects.map(&:id)) if all_collection_objects

    rows.each do |mr|
      current = mr.reference_count - 1

      if current == 0
        mr.delete
      else
        mr.update_columns(reference_count: current)
      end
    end
  end

  def self.human_name
    self.name.demodulize.humanize
  end

  # @return [Array]
  #   the otus "defined" by this matrix row item
  # override
  def otus
    false
  end

  # @return [Array]
  #   the collection objects "defined" by this matrix row item
  # override
  def collection_objects
    false
  end

  # @return [Array]
  #   the required attributes for this subclass
  # override
  def self.subclass_attributes
    []
  end

  protected

  def other_subclass_attributes_not_set
    (ALL_STI_ATTRIBUTES - self.class.subclass_attributes).each do |attr|
      errors.add(attr, 'is not valid for this type of matrix row item') if !send(attr).blank?
    end
  end

  def type_is_subclassed
    if !MATRIX_ROW_ITEM_TYPES[type]
      errors.add(:type, 'type must be a valid subclass')
    end
  end
end

Dir[Rails.root.to_s + '/app/models/matrix_row_item/**/*.rb'].each { |file| require_dependency file }
