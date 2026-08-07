# Each ObservationMatrixColumnItem is set containing 1 or more descriptors.
#
# @!attribute observation_matrix_id
#   @return [Integer] id of the matrix
#
# @!attribute descriptor_id
#   @return [Integer] id of the descriptor (a single/static subclass)
#
# @!attribute controlled_vocabulary_term_id
#   @return [Integer] id of the Keyword (a dynamic subclass)
#
# @!attribute type
#   @return [String] the column type
#
# @!attribute position
#   @return [Integer] a sort order
#
class ObservationMatrixColumnItem < ApplicationRecord
  include Housekeeping
  include Shared::Identifiers
  include Shared::Notes
  include Shared::Tags
  include Shared::IsData

  acts_as_list scope: [:observation_matrix_id, :project_id]

  ALL_STI_ATTRIBUTES = [:descriptor_id, :controlled_vocabulary_term_id].freeze

  belongs_to :observation_matrix, inverse_of: :observation_matrix_column_items

  # TODO: remove from subclasses WHY does this need to be here
  # belongs_to :descriptor, inverse_of: :observation_matrix_column_items

  # See above and corresponding questions
  # belongs_to :controlled_vocabulary_term, inverse_of: :observation_matrix_column_items

  validates_presence_of :observation_matrix
  validate :other_subclass_attributes_not_set, if: -> { !type.blank? }

  after_save :update_matrix_columns
  after_destroy :cleanup_matrix_columns

  # @return [Array]
  #   of all objects this row references
  def column_objects
    objects = []

    objects.push *descriptors if descriptors
    objects
  end

  def cleanup_matrix_columns
    return true unless descriptors.size > 0
    ObservationMatrixColumn.where(descriptor_id: descriptors.map(&:id), observation_matrix: observation_matrix).each do |mc|
      cleanup_single_matrix_column(mc.descriptor_id, mc)
    end
    true
  end

  def update_matrix_columns
    descriptors.each do |d|
      update_single_matrix_column(d)
    end
  end

  def cleanup_single_matrix_column(descriptor_id, mc = nil)
    mc ||= ObservationMatrixColumn.where(
      descriptor_id: descriptor_id,
      observation_matrix: observation_matrix
    ).first
    decrement_matrix_column_reference_count(mc) if !mc.nil?
  end

  def decrement_matrix_column_reference_count(mc)
    current = mc.reference_count - 1
    if current == 0
      mc.delete
    else
      mc.update_columns(reference_count: current)
      mc.update_columns(cached_observation_matrix_column_item_id: nil) if current == 1 && type =~ /Single/ # we've deleted the only single, so the last must be a Dynamic/Tagged
    end
  end

  def find_or_build_column(descriptor)
    ObservationMatrixColumn.find_or_initialize_by(
      observation_matrix: observation_matrix,
      descriptor: descriptor)
  end

  # creates or finds and updates count, always
  def update_single_matrix_column(descriptor)
    mc = find_or_build_column(descriptor)
    mc.save! if !mc.persisted?

    increment_matrix_column_reference_count(mc)
  end

  def increment_matrix_column_reference_count(mc)
    mc.update_columns(reference_count: (mc.reference_count || 0) + 1)
    mc.update_columns(cached_observation_matrix_column_item_id: id) if type =~ /Single/
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

  # @return [Array] of ObservationMatrixColumnItems
  def self.batch_create(params)
    case params[:batch_type]
    when 'tags'
      batch_create_from_tags(params[:keyword_id], params[:klass], params[:observation_matrix_id])
    when 'pinboard'
      batch_create_from_pinboard(params[:observation_matrix_id], params[:project_id], params[:user_id], params[:klass])
    when 'matrix_clone'
      batch_create_from_observation_matrix(params[:observation_matrix_id], params[:target_observation_matrix_id], params[:project_id], params[:user_id])
    when 'descriptor_id'
      batch_create_by_descriptor_id(params[:observation_matrix_id], params[:descriptor_id], params[:project_id], params[:user_id])

    when 'observation_matrix_column_item_id'
      batch_create_by_observation_matrix_column_item_id(params[:observation_matrix_id], params[:observation_matrix_column_item_id], params[:project_id], params[:user_id])
    end
  end

  # @return [Array, false]
  def self.batch_create_by_observation_matrix_column_item_id(observation_matrix_id, observation_matrix_column_item_id, project_id, user_id )
    created = []
    matrix  = ObservationMatrix.where(project_id: project_id).find(observation_matrix_id)
    ids = [observation_matrix_column_item_id].flatten.compact
    return false if matrix.nil?

    ObservationMatrixColumnItem.transaction do
      begin
        ids.each do |i|
          o = ObservationMatrixColumnItem.where(project_id: project_id).find(i)
          c = o.dup
          c.observation_matrix = matrix
          c.created_by_id = user_id
          c.save!
          created.push c
        end
      rescue ActiveRecord::RecordInvalid => e
        next
      end
    end
    return created
  end

  # @return [Array, false]
  def self.batch_create_by_descriptor_id(observation_matrix_id, descriptor_id, project_id, user_id )
    created = []
    matrix  = ObservationMatrix.where(project_id: project_id).find(observation_matrix_id)
    ids = [descriptor_id].flatten.compact
    return false if matrix.nil?

    ObservationMatrixColumnItem.transaction do
      begin
        ids.each do |i|
          c = ObservationMatrixColumnItem::Single::Descriptor.create!(
            descriptor: Descriptor.where(project_id: project_id).find(i),
            observation_matrix_id: matrix.id,
            project_id: project_id,
            created_by_id: user_id)
          created.push c
        end
      rescue ActiveRecord::RecordInvalid => e
        next
      end
    end
    return created
  end

  # @return [Array, false]
  def self.batch_create_from_observation_matrix(from_observation_matrix_id, to_observation_matrix_id, project_id, user_id )
    created = []

    from_matrix = ObservationMatrix.where(project_id: project_id).find(from_observation_matrix_id)
    to_matrix = ObservationMatrix.where(project_id: project_id).find(to_observation_matrix_id)

    return false if from_matrix.nil? || to_matrix.nil?

    ObservationMatrixColumnItem.transaction do
      begin

        from_matrix.observation_matrix_column_items.each do |oci|
          c = oci.dup
          c.observation_matrix = to_matrix
          c.created_by_id = user_id
          c.save!
          created.push c
        end
      rescue ActiveRecord::RecordInvalid => e
        next
      end
    end
    return created
  end

  # @params klass [String] the subclass of the Descriptor ike `Descriptor::Working` or `Descriptor::Continuous`
  # @return [Array, false]
  def self.batch_create_from_tags(keyword_id, klass, observation_matrix_id)
    created = []
    ObservationMatrixColumnItem.transaction do
      begin
        if klass
          klass.constantize.joins(:tags).where(tags: {keyword_id: keyword_id } ).each do |o|
            created.push create_for(o, observation_matrix_id)
          end
        else
          created += create_for_tags(
            Tag.where(
              keyword_id: keyword_id,
              tag_object_type: 'Descriptor').all,
             observation_matrix_id
          )
        end
      rescue ActiveRecord::RecordInvalid => e
        raise # return false
      end
    end
    return created
  end

  # @params klass [String] the class name like `Otu` or `CollectionObject`
  # @return [Array, false]
  def self.batch_create_from_pinboard(observation_matrix_id, project_id, user_id, klass)
    return false if observation_matrix_id.blank? || project_id.blank? || user_id.blank?
    created = []
    ObservationMatrixColumn.transaction do
      begin
        if klass
          klass.constantize.joins(:pinboard_items).where(pinboard_items: {user_id: user_id, project_id: project_id}).each do |o|
            created.push create_for(o, observation_matrix_id)
          end
        else
          created += create_for_pinboard_items(
            PinboardItem.where(project_id: project_id, user_id: user_id, pinned_object_type: 'Descriptor').all,
            observation_matrix_id
          )
        end
      rescue ActiveRecord::RecordInvalid => e
        return false
      end
    end
    return created
  end

  # @return [Boolean]
  #   whether this is a dynamic or fixed class
  #   override in subclasses
  def is_dynamic?
    false
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
  #   create observation matrix column items for all scope items
  def self.create_for_pinboard_items(pinboard_item_scope, observation_matrix_id)
    a = []
    pinboard_item_scope.each do |o|
      a.push create_for(o.pinned_object, observation_matrix_id)
    end
    a
  end

  def self.create_for(object, observation_matrix_id)
    ObservationMatrixColumnItem::Single::Descriptor.create!(
      observation_matrix_id: observation_matrix_id,
      descriptor: object)
  end

  def other_subclass_attributes_not_set
    (ALL_STI_ATTRIBUTES - self.class.subclass_attributes).each do |atr|
      errors.add(atr, 'is not valid for this type of observation matrix column item') if !send(atr).blank?
    end
  end

end

Dir[Rails.root.to_s + '/app/models/observation_matrix_column_item/**/*.rb'].each { |file| require_dependency file }
