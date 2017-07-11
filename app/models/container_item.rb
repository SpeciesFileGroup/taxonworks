# A container item is something that has been "localized to" a container.
# We can't say that it is "in" the container, because not all containers (e.g. a pin with three specimens) contain the object.
# By "localized to" we mean that if you can find the container, then its contents should also be locatable.
#
# This concept is a graph edge defining the relationship to the container.
#
# @!attribute parent_id
#   @return [Integer]
#     id of the ContainerItem whose contained_object is a Container, i.e. the container of this ContainerItem
#
# @!attribute contained_object_id
#   @return [Integer]
#     the id of the object that is contained (Rails polymorphic)
#
# @!attribute contained_object_type
#   @return [String]
#     the type of the object that is contained (Rails polymorphic)
#
# @!attribute localization
#   @return [String]
#   some additional modifier arbitrarily defining the position of this item, aka disposition, always relative to enclosing container
#
# @!attribute project_id
#   @return [Integers
#   the project ID
#
## @!attribute disposition_x
#   @return [Integer]
#     a x coordinate for this item in its container
#
## @!attribute disposition_y
#   @return [Integer]
#     a y coordinate for this item in its container
#
## @!attribute disposition_z
#   @return [Integer]
#     a z coordinate for this item in its container
#
class ContainerItem < ApplicationRecord
  has_closure_tree

  include Housekeeping
  include Shared::IsData

  attr_accessor :global_entity

  belongs_to :contained_object, polymorphic: true

  # !! this will prevent accepts_nested assignments if we add this
  validates_presence_of :contained_object

  validate :parent_contained_object_is_container
  validate :contained_object_is_container_when_parent_id_is_blank
  validate :contained_object_is_unique
  validate :object_fits_in_container
  validate :position_is_not_replicated

  scope :containers, -> { where(contained_object_type: 'Container') }
  scope :not_containers, -> { where.not(contained_object_type: 'Container') }
  scope :containing_collection_objects, -> {where(contained_object_type: 'CollectionObject')}

  def container=(object)
    if object.metamorphosize.class.to_s == 'Container'
      if parent
        parent.contained_object = object
      else
        self.parent = ContainerItem.new(contained_object: object)
      end

      parent.save! if !parent.new_record?
      self.save! unless self.new_record?
    end
  end

  # @return [container]
  #   the container for this ContainerItem
  def container
    parent(true).try(:contained_object) || Container.none
  end

  def global_entity
    contained_object.to_global_id if contained_object.present?
  end

  def global_entity=(entity)
    contained_object = GlobalID::Locator.locate entity
  end

  def self.find_for_autocomplete(params)
    Queries::ContainerItemAutocompleteQuery.new(params[:term]).all.where(project_id: params[:project_id])
  end


  protected

  def object_fits_in_container
    if parent
      %w{x y z}.each do |coord|
        c = self.send("disposition_#{coord}")
        errors.add("disposition_#{coord}".to_sym, 'is larger than the container size') if c && parent.contained_object.send("size_#{coord}") < c
      end
    end
  end

  def position_is_not_replicated
    if parent && (disposition_x || disposition_y || disposition_z)
      if ContainerItem.where.not(id: id).
          where(parent: parent,
                disposition_x: disposition_x,
                disposition_y: disposition_y,
                disposition_z: disposition_z ).count > 0
        errors.add(:base, 'position is already taken in this container')
      end
    end
  end

  # if the contained_object is a CollectionObject, it must have a parent container reference
  def contained_object_is_container_when_parent_id_is_blank
    if parent_id.blank?
      errors.add(:parent_id, 'can only be blank if object is a container') if contained_object_type != 'Container'
    end
  end

  # parent_id links an object to a container through container_item
  def parent_contained_object_is_container
    unless parent_id.blank? && parent.nil?
      errors.add(:parent_id, "can only be set if parent's contained object is a container") if parent.contained_object_type != 'Container'
    end
  end

  def contained_object_is_unique
    if ContainerItem.where.not(id: id).where(project_id: project_id, contained_object_id: contained_object_id, contained_object_type: contained_object_type).count > 0
      errors.add(:contained_object, 'is already in a container_item')
    end
  end




end
