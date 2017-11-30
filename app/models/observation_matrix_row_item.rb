#
# A MatrixRowItem defines a set of one OR MORE matrix rows depending on their class.
#
class ObservationMatrixRowItem < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Identifiers
  include Shared::IsData
  include Shared::Tags
  include Shared::Notes

  acts_as_list

  ALL_STI_ATTRIBUTES = [:otu_id, :collection_object_id, :controlled_vocabulary_term_id]

  belongs_to :observation_matrix

  validates_presence_of :observation_matrix
  validate :type_is_subclassed
  validate :other_subclass_attributes_not_set, if: -> {!type.blank?}

  after_save :update_matrix_rows
  after_destroy :cleanup_matrix_rows

  def update_matrix_rows
    objects = Array.new
    objects.push *otus if otus
    objects.push *collection_objects if collection_objects

    objects.each do |o|
      update_single_matrix_row o
    end
  end

  def cleanup_matrix_rows
    rows = Array.new
    rows.push *ObservationMatrixRow.where(observation_matrix: observation_matrix, otu_id: otus.map(&:id)) if otus
    rows.push *ObservationMatrixRow.where(observation_matrix: observation_matrix, collection_object_id: collection_objects.map(&:id)) if collection_objects

    rows.each do |mr|
      decrement_matrix_row_reference_count mr
    end
  end

  def update_single_matrix_row(object)
    mr = nil

    if object.is_a? Otu
      mr = ObservationMatrixRow.find_or_create_by(observation_matrix: observation_matrix, otu: object)
    elsif object.is_a? CollectionObject
      mr = ObservationMatrixRow.find_or_create_by(observation_matrix: observation_matrix, collection_object: object)
    end

    mr.update_columns(reference_count: mr.reference_count + 1)
  end

  def cleanup_single_matrix_row(object)
    mr = nil

    if object.is_a? Otu
      mr = ObservationMatrixRow.where(observation_matrix: observation_matrix, otu_id: object.id).first
    elsif object.is_a? CollectionObject
      mr = ObservationMatrixRow.where(observation_matrix: observation_matrix, collection_object_id: object.id).first
    end

    decrement_matrix_row_reference_count mr
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

  # @return [Object]
  #   the object used to define the set of matrix rows
  # override
  def matrix_row_item_object
    nil
  end

  # @return [matrix_row_item_object, nil]
  def object_is?(object_type)
    matrix_row_item_object.class.name == object_type ? matrix_row_item_object : nil
  end

  protected

  def other_subclass_attributes_not_set
    (ALL_STI_ATTRIBUTES - self.type.constantize.subclass_attributes).each do |attr|
      errors.add(attr, 'is not valid for this type of observation matrix row item') if !send(attr).blank?
    end
  end

  def type_is_subclassed
    if !MATRIX_ROW_ITEM_TYPES[type]
      errors.add(:type, 'type must be a valid subclass')
    end
  end

  private

  def decrement_matrix_row_reference_count(mr)
    current = mr.reference_count - 1

    if current == 0
      mr.delete
    else
      mr.update_columns(reference_count: current)
    end
  end
end

Dir[Rails.root.to_s + '/app/models/observation_matrix_row_item/**/*.rb'].each { |file| require_dependency file }
