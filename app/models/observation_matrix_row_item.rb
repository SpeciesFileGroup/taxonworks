# Each ObservationMatrixRowItem is set of Otus or Collection Objects (1 or more)
#
# @!attribute observation_matrix_id 
#   @return [Integer] id of the matrix 
#
# @!attribute otu_id 
#   @return [Integer] id of an (single) Otu based row
#
# @!attribute collection_object_id 
#   @return [Integer] id of a (single) CollectObject based row
#
# @!attribute position 
#   @return [Integer] a sort order 
#
# @!attribute cached_observation_matrix_row_item_id
#   @return [Integer] if the column item is derived from a ::Single<FOO> subclass, the id of that instance
#
class ObservationMatrixRowItem < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Identifiers
  include Shared::IsData
  include Shared::Tags
  include Shared::Notes

  acts_as_list scope: [:observation_matrix_id, :project_id]

  ALL_STI_ATTRIBUTES = [:otu_id, :collection_object_id, :controlled_vocabulary_term_id, :taxon_name_id].freeze

  belongs_to :observation_matrix, inverse_of: :observation_matrix_row_items
  belongs_to :otu, inverse_of: :observation_matrix_row_items
  belongs_to :collection_object, inverse_of: :observation_matrix_row_items

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
    rows = []
    rows.push *ObservationMatrixRow.where(observation_matrix: observation_matrix, otu_id: otus.map(&:id)) if otus
    rows.push *ObservationMatrixRow.where(observation_matrix: observation_matrix, collection_object_id: collection_objects.map(&:id)) if collection_objects

    rows.each do |mr|
      decrement_matrix_row_reference_count(mr)
    end
  end

  def update_single_matrix_row(object)
    mr = nil

    if object.is_a? Otu
      mr = ObservationMatrixRow.find_or_create_by(observation_matrix: observation_matrix, otu: object )
    elsif object.is_a? CollectionObject
      mr = ObservationMatrixRow.find_or_create_by(observation_matrix: observation_matrix, collection_object: object)
    end
    increment_matrix_row_reference_count(mr)
  end

  def cleanup_single_matrix_row(object)
    mr = nil

    if object.is_a? Otu
      mr = ObservationMatrixRow.where(observation_matrix: observation_matrix, otu_id: object.id).first
    elsif object.is_a? CollectionObject
      mr = ObservationMatrixRow.where(observation_matrix: observation_matrix, collection_object_id: object.id).first
    end

    decrement_matrix_row_reference_count(mr)
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

  # @return [Boolean]
  #   whether this is a dynamic or fixed class
  #   override in subclasses
  def is_dynamic?
    false
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

  # @return [Array] of ObservationMatrixRowItems
  def self.batch_create(params)
    case params[:batch_type]
    when 'tags'
      batch_create_from_tags(params[:keyword_id], params[:klass], params[:observation_matrix_id])
    when 'pinboard'
      batch_create_from_pinboard(params[:observation_matrix_id], params[:project_id], params[:user_id], params[:klass])
    end
  end

  # @params klass [String] the class name like `Otu` or `CollectionObject`
  # @return [Array, false]
  def self.batch_create_from_tags(keyword_id, klass, observation_matrix_id)
    created = []
    ObservationMatrixRowItem.transaction do
      begin
        if klass
          klass.constantize.joins(:tags).where(tags: {keyword_id: keyword_id} ).each do |o|
            created.push create_for(o, observation_matrix_id)
          end
        else
          created += create_for_tags(
            Tag.where(keyword_id: keyword_id, tag_object_type: ['Otu', 'CollectionObject']).all,
            observation_matrix_id
          )       
        end
      rescue ActiveRecord::RecordInvalid => e
        return false
      end
    end
    return created
  end

  # @params klass [String] the class name like `Otu` or `CollectionObject`
  # @return [Array, false]
  def self.batch_create_from_pinboard(observation_matrix_id, project_id, user_id, klass)
    return false if observation_matrix_id.blank? || project_id.blank? || user_id.blank?
    created = []
    ObservationMatrixRow.transaction do
      begin
        if klass
          klass.constantize.joins(:pinboard_items).where(pinboard_items: {user_id: user_id, project_id: project_id}).each do |o|
            created.push create_for(o, observation_matrix_id)
          end
        else
          created += create_for_pinboard_items(
            PinboardItem.where(project_id: project_id, user_id: user_id, pinned_object_type: ['Otu', 'CollectionObject']).all,
            observation_matrix_id
          )
        end
      rescue ActiveRecord::RecordInvalid => e
        return false
      end
    end
    return created
  end

  private

  # @return [Array]
  def self.create_for_tags(tag_scope, observation_matrix_id)
    a = []
    tag_scope.each do |o|
      a.push create_for(o.tag_object, observation_matrix_id)
    end
    a
  end

  # @param pinboard_item_scope [PinboardItem Scope]
  # @return [Array]
  #   create observation matrix row items for all scope items
  def self.create_for_pinboard_items(pinboard_item_scope, observation_matrix_id)
    a = []
    pinboard_item_scope.each do |o|
      a.push create_for(o.pinned_object, observation_matrix_id)
    end
    a 
  end

  def self.create_for(object, observation_matrix_id)
    p = { observation_matrix_id: observation_matrix_id }
    case object.class.base_class.name
    when 'Otu'
      p[:otu_id] = object.id
      p[:type] = 'ObservationMatrixRowItem::SingleOtu'
    when 'CollectionObject'
      p[:collection_object_id] = object.id
      p[:type] = 'ObservationMatrixRowItem::SingleCollectionObject'
    else
      raise 
    end
    ObservationMatrixRowItem.create!(p)
  end

  def decrement_matrix_row_reference_count(mr)
    current = mr.reference_count - 1

    if current == 0
      mr.delete
    else
      mr.update_columns(reference_count: current)
      mr.update_columns(cached_observation_matrix_row_item_id: nil) if current == 1 && type =~ /Single/ # we've deleted the only single, so the last must be a Dynamic/Tagged
    end
  end

  def increment_matrix_row_reference_count(mr)
    mr.update_columns(reference_count: mr.reference_count + 1)
    mr.update_columns(cached_observation_matrix_row_item_id: id) if type =~ /Single/
  end

end

Dir[Rails.root.to_s + '/app/models/observation_matrix_row_item/**/*.rb'].each { |file| require_dependency file }
