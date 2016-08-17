# A container localizes the proximity of one ore more physical things, at this point in TW this is restricted to a number of collection objects.
#
# @!attribute type
#   @return [String]
#     STI, the type of container
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute name
#   @return [String]
#     abitrary name of this container
#
# @!attribute disposition
#   @return [String]
#     a free text description of the position of this container
#
class Container < ActiveRecord::Base

  include Housekeeping
  include Shared::IsData
  include Shared::Identifiable

  include Shared::Containable

  include Shared::Taggable
  include SoftValidation

  has_many :collection_profiles

  validates :type, presence: true
  validate :type_is_valid

  before_destroy :check_for_contents

  # @return [ContainerItem Scope]
  #    return all ContainerItems contained in this container (non recursive)
  def container_items
    container_item(true).try(:children) || ContainerItem.none
  end

  # @return [ContainerItem Scope]
  #   return all ContainerItems contained in this container (recursive)
  def all_container_items
    container_item(true).try(:descendants) || ContainerItem.none
  end

  # @return [Array]
  #   return all #contained_object(s) (non-recursive)
  def contained_objects
    return [] if !container_item(true)
    container_item.children.map(&:contained_object)
  end

  # @return [Array]
  #   return all #contained_object(s) (recursive)
  def all_contained_objects
    return [] if !container_item(true)
    container_item.descendants.map(&:contained_object)
  end

  # # @return [Array] of CollectionObject#id of this container's CollectionObjects only (no recursion)
  # def collection_objects
  #   container_items.containing_collection_objects.map(&:contained_object)
  # end

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
    all_container_items.containing_collection_objects.pluck(&:id)
  end

  # @return [Boolean]
  #    add the objects to this container
  def add_container_items(objects)
    return false if new_record?
    begin
     Container.transaction do
       ci = container_item
       ci ||= ContainerItem.create!(contained_object: self)

       objects.each do |o|
         return false if o.new_record? || !o.containable? # does this roll back transaction
         ContainerItem.create!(parent: ci, contained_object: o)
       end

     end
   rescue ActiveRecord::RecordInvalid
     return false
   end
    true
  end

  # @return [Boolean]
  #   regardless whether size is defined, whether there is anything in this container (non-recursive)
  def is_empty?
    !container_items.any?
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
    size - in_container
  end

  # @return [Integer, nil]
  #   the total number of "slots" or "spaces" this container has, it's size
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

  def self.find_for_autocomplete(params)
    Queries::ContainerAutocompleteQuery.new(params[:term], project_id: params[:project_id]).result
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
  #   places all objects in a new, container, saves it off, all objects must not be new_records
  def self.containerize(objects, klass = Container::Virtual)
    c = nil
    begin
      Container.transaction do
        c = klass.create()
        ci = ContainerItem.create(contained_object: c)

        objects.each do |o|
          return false if o.new_record?
          ContainerItem.create(parent: ci, contained_object: o)
        end

      end
    rescue ActiveRecord::RecordInvalid
      return false
    end
    c
  end


  protected

  def type_is_valid
    raise ActiveRecord::SubclassNotFound, 'Invalid subclass' if type && !CONTAINER_TYPES.include?(type)
  end

  def check_for_contents
    if container_items.any?
      errors.add(:base, 'is not empty, empty it before destroying it')
      return false
    end
  end


end

Dir[Rails.root.to_s + '/app/models/container/**/*.rb'].each { |file| require_dependency file }
