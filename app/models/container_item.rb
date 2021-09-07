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
  # @return class
  #   this method calls Module#module_parent
  # TODO: This method can be placed elsewhere inside this class (or even removed if not used)
  #       when https://github.com/ClosureTree/closure_tree/issues/346 is fixed.
  def self.parent
    self.module_parent
  end

  has_closure_tree

  include Housekeeping
  include Shared::IsData

  attr_accessor :global_entity

  attr_accessor :container_id

  belongs_to :contained_object, polymorphic: true

  # !! this will prevent accepts_nested assignments if we add this
  validates_presence_of :contained_object_id

  validate :parent_contained_object_is_container
  validate :contained_object_is_container_when_parent_id_is_blank
  validate :contained_object_is_unique
  validate :object_fits_in_container
  validate :position_is_not_replicated
  validate :parent_is_provided_if_object_is_not_container

  scope :containers, -> { where(contained_object_type: 'Container') }
  scope :not_containers, -> { where.not(contained_object_type: 'Container') }
  scope :containing_collection_objects, -> {where(contained_object_type: 'CollectionObject')}

  # before_save :set_container, unless: Proc.new {|n| n.container_id.nil? || errors.any? }
 
  # @params object [Container]
  def container=(object)
    if object.metamorphosize.kind_of?(Container)
      if self.parent
        self.parent.contained_object = object
      else
        # This self required?!
        self.parent = ContainerItem.new(contained_object: object)
      end

      self.parent.save! if !self.parent.new_record?
      save! unless new_record?
    end
  end

  # @param value [a Container#id]
  def container_id=(value)
    @container_id = value
    set_container
  end

  # @return [Container, nil]
  #   the immediate container for this ContainerItem
  def container
    parent.try(:contained_object)
  end

  # TODO: this is silly, type should be the same
  # @return [GlobalID]
  #   ! not a string
  def global_entity
    contained_object.to_global_id if contained_object.present?
  end

  # @params entity [String, a global id]
  def global_entity=(entity)
    self.contained_object = GlobalID::Locator.locate(entity)
  end

  protected

  def set_container
    c = Container.find(container_id)

    # Already in some container
    if parent && parent.persisted? 
      self.parent.update_columns(contained_object_type: 'Container', contained_object_id: c.id)
    # Not in container
    else
      # In same container as something else
      if d = c.container_item
        self.parent = d
      # In a new container
      else
        self.parent = ContainerItem.create!(contained_object: c) 
      end
    end

    # self.parent.save! if !self.parent.new_record?
    # save! unless new_record?
  end

  def object_fits_in_container
    if parent
      %w{x y z}.each do |coord|
        c = send("disposition_#{coord}")
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

  # If the contained_object is a CollectionObject, it must have a parent container reference
  def contained_object_is_container_when_parent_id_is_blank
    if parent_id.blank? && container_id.blank? && container.blank?
      errors.add(:parent_id, 'can only be blank if object is a container') if contained_object_type != 'Container'
    end
  end

  # parent_id links an object to a container through container_item
  def parent_contained_object_is_container
    unless parent_id.blank? && parent.nil?
      errors.add(:parent_id, "can only be set if parent's contained object is a container") if parent.contained_object_type != 'Container'
    end
  end

  def parent_is_provided_if_object_is_not_container
    if !(contained_object_type =~ /Container/) && !parent 
      errors.add(:parent, "must be set if contained object is not a container")
    end
  end

  def contained_object_is_unique
    if ContainerItem.where.not(id: id).where(project_id: project_id, contained_object_id: contained_object_id, contained_object_type: contained_object_type).count > 0
      errors.add(:contained_object, 'is already in a container_item')
    end
  end

end
