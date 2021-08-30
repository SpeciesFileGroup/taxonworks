# A container localizes the proximity of one ore more physical things, at this point in TW this is restricted to a number of collection objects.
# Objects are placed in containers by reference to a ContainerItem.
#
# @!attribute type
#   @return [String]
#     STI, the type of container
#
# @!attribute project_id
#   @return [Integer]
#
# @!attribute name
#   @return [String]
#     abitrary name of this container
#
# @!attribute disposition
#   @return [String]
#     a free text description of the position of this container
#
# @!attribute size_x 
#   @return [Int]
#     the number of slots in the x dimension 
#
# @!attribute size_y 
#   @return [Int]
#     the number of slots in the y dimension 
#
# @!attribute size_z 
#   @return [Int]
#     the number of slots in the z dimension 
#
# @!attribute print_label 
#   @return [String]
#     text of a label to print for this container 
#
class Container < ApplicationRecord

  include Housekeeping
  include Shared::Identifiers
  include Shared::Containable
  include Shared::Tags
  include SoftValidation
  include Shared::Loanable
  include Shared::Labels 
  include Shared::IsData

  has_many :collection_profiles

  validates :type, presence: true
  validate :type_is_valid

  before_destroy :check_for_contents

  # @return [ContainerItem Scope]
  #    return all ContainerItems contained in this container (non recursive)
  # TODO: fix Please call `reload_container_item` instead. (called from container_items at /Users/jrflood/src/taxonworks/app/models/container.rb:43)
  def container_items
    reload_container_item.try(:children) || ContainerItem.none
  end

  # @return [ContainerItem Scope]
  #   return all ContainerItems contained in this container (recursive)
  def all_container_items
    reload_container_item.try(:descendants) || ContainerItem.none
  end

  # @return [Array]
  #   return all #contained_object(s) (non-recursive)
  def contained_objects
    return [] if !reload_container_item
    container_item.children.map(&:contained_object)
  end

  # @return [Array]
  #   return all #contained_object(s) (recursive)
  def all_contained_objects
    return [] if !reload_container_item
    container_item.descendants.map(&:contained_object)
  end

  # @return [Array] of CollectionObject#id of this container's CollectionObjects only (with recursion)
  def collection_objects
    all_container_items.containing_collection_objects.map(&:contained_object)
  end

  # @return [Array] of CollectionObject#id of this container's contents (no recursion)
  def collection_object_ids
    container_items.containing_collection_objects.pluck(&:id)
  end

  # @return [Array] of CollectionObject#id of this container's contents (recursive)
  def all_collection_object_ids
    # all_container_items.containing_collection_objects.pluck(&:id)
    collection_objects.map(&:id)
  end

  # @return [Boolean]
  #   regardless whether size is defined, whether there is anything in this container (non-recursive)
  def is_empty?
    !container_items.any?
  end

  # @return [Boolean]
  #   whether this container is nested in other containers
  def is_nested?
    container_item && container_item.ancestors.any?
  end

  # @return [Boolean]
  #   true if size is defined, and there is no space left in this container (non-recursive)
  def is_full?
    available_space == 0
  end

  # @return [Integer]
  #   the free space in this container (non-recursive)
  def available_space
    in_container = container_items.count
    if size 
      size - in_container
    else
      nil
    end
  end

  # @return [Integer, nil]
  #   the total number of "slots" or "spaces" this container has, it's size 
  # TODO: reserved word?
  def size
    return nil if size_x.blank? && size_y.blank? && size_z.blank?
    if size_x
      if size_y
        if size_z
          size_x * size_y * size_z
        else
          size_x * size_y
        end
      else
        size_x
      end
    end
  end

  # @return [String]
  #   the "common name" of this class
  def self.class_name
    self.name.demodulize.underscore.humanize.downcase
  end

  # @return [Array of Strings]
  #   valid containers class names that this container can fit in, by default none
  def self.valid_parents
    []
  end

  # @return [Container]
  #   places all objects in a new, parent-less container, saves it off,
  #   None of the objects are permitted to be new_records.
  #   !! If an object is in another container it is moved to the new container created here.
  def self.containerize(objects, klass = Container::Virtual)
    new_container = nil
    begin
      Container.transaction do
        new_container = klass.create()
        ci_parent     = ContainerItem.create(contained_object: new_container)

        objects.each do |o|
          raise ActiveRecord::RecordInvalid if o.new_record?
          if o.container_item.nil? # contain an uncontained objet
            ContainerItem.create(parent: ci_parent, contained_object: o)
          else # move the object if it's in a container already
            o.container_item.update(parent_id: ci_parent.id)
          end
        end
      end
    rescue ActiveRecord::RecordInvalid
      return false
    end
    new_container
  end

  # @return [Boolean]
  #    add the objects to this container
  def add_container_items(objects)
    return false if new_record?

    # TODO: Figure out why this reload is required.
    self.reload # this seems to be required under some (as yet undefined) circumstances.
    begin
      Container.transaction do
        ci_parent = container_item
        ci_parent ||= ContainerItem.create!(contained_object: self)

        objects.each do |o|
          return false if o.new_record? || !o.containable? # does this roll back transaction
          if o.container_item.nil?
            ContainerItem.create!(parent: ci_parent, contained_object: o)
          else # move the object to a new container
            # this triggers the closure_tree parenting/re-parenting
            o.container_item.update(parent_id: ci_parent.id)
          end
        end
      end
    rescue ActiveRecord::RecordInvalid
      return false
    end
    true
  end

  protected

  def type_is_valid
    raise ActiveRecord::SubclassNotFound, 'Invalid subclass' if type && !CONTAINER_TYPES.include?(type)
  end

  def check_for_contents
    if container_items.any?
      errors.add(:base, 'is not empty, empty it before destroying it')
      # return false
      throw :abort
    end
  end
end

Dir[Rails.root.to_s + '/app/models/container/**/*.rb'].each { |file| require_dependency file }
