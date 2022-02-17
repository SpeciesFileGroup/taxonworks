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

class ObservationMatrixRowItem < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Identifiers
  include Shared::Tags
  include Shared::Notes
  include Shared::IsData
  include SoftValidation
  include Shared::ObservationIndex

  acts_as_list scope: [:observation_matrix_id, :project_id]

  belongs_to :observation_matrix, inverse_of: :observation_matrix_row_items
  belongs_to :observation_object, polymorphic: true

  validates_presence_of :observation_matrix, :observation_object

  after_save :update_matrix_rows
  after_destroy :cleanup_matrix_rows

  # @return [Array]
  #   of all objects this row references
  # required/defined in subclasses
  def observation_objects
    []
  end

  def update_matrix_rows
     observation_objects.each do |o|
      update_single_matrix_row o
    end
  end

  def cleanup_matrix_rows
    return true if observation_objects.count == 0
    ObservationMatrixRow.where(observation_matrix: observation_matrix, observation_object: observation_objects).each do |mr|
      decrement_matrix_row_reference_count(mr)
    end
    true
  end

  def find_or_build_row(object)
    ObservationMatrixRow.find_or_initialize_by(observation_matrix: observation_matrix, observation_object: object)
  end

  def update_single_matrix_row(object)
    mr = find_or_build_row(object)
    mr.save! if !mr.persisted?
    increment_matrix_row_reference_count(mr)
  end

  # Not named "destroy_" because it doesn't always delete row
  def cleanup_single_matrix_row(object)
    mr = ObservationMatrixRow.where(observation_matrix: observation_matrix, observation_object: object).first
    decrement_matrix_row_reference_count(mr) if !mr.nil?
  end

  def self.human_name
    self.name.demodulize.humanize
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
          klass.safe_constantize.joins(:tags).where(tags: {keyword_id: keyword_id} ).each do |o|
            created.push ObservationMatrixRowItem::Single.create!(observation_matrix_id: observation_matrix_id, observation_object: o)
          end
        else
          created += create_for_tags(
            Tag.where(keyword_id: keyword_id, tag_object_type: OBSERVABLE_TYPES).all,
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
          klass.safe_constantize.joins(:pinboard_items).where(pinboard_items: {user_id: user_id, project_id: project_id}).each do |o|
            created.push ObservationMatrixRowItem::Single.create!(observation_matrix_id: observation_matrix_id, observation_object: o)
          end
        else
          created += create_for_pinboard_items(
            PinboardItem.where(project_id: project_id, user_id: user_id, pinned_object_type: OBSERVABLE_TYPES).all,
            observation_matrix_id
          )
        end
      rescue ActiveRecord::RecordInvalid => e
        raise
      end
    end
    return created
  end

  private

  # @return [Array]
  def self.create_for_tags(tag_scope, observation_matrix_id)
    a = []
    tag_scope.each do |o|
      a.push ObservationMatrixRowItem::Single.create!(observation_matrix_id: observation_matrix_id, observation_object: o.tag_object)
    end
    a
  end

  # @param pinboard_item_scope [PinboardItem Scope]
  # @return [Array]
  #   create observation matrix row items for all scope items
  def self.create_for_pinboard_items(pinboard_item_scope, observation_matrix_id)
    a = []
    pinboard_item_scope.each do |o|
      a.push ObservationMatrixRowItem::Single.create!(observation_matrix_id: observation_matrix_id, observation_object: o.pinned_object)
    end
    a
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

  # TODO: Should change behaviour of cached_
  # to only populate with id when reference count == 1
  # that way we could delete rows
  def increment_matrix_row_reference_count(mr)
    mr.update_columns(reference_count: (mr.reference_count || 0) +  1)
    mr.update_columns(cached_observation_matrix_row_item_id: id) if type =~ /Single/
  end
end

Dir[Rails.root.to_s + '/app/models/observation_matrix_row_item/**/*.rb'].each { |file| require_dependency file }
