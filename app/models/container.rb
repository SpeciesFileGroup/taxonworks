# A container localizes the proximity of one ore more physical things, at this point in TW this is restricted to a number of collection objects.
#
# @!attribute parent_id
#   @return [Integer]
#     identifies the container this container is contained in
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

  has_closure_tree

  include Housekeeping
  include Shared::IsData
  include Shared::Identifiable
  include Shared::Containable
  include Shared::Taggable
  include SoftValidation

  has_many :container_items, inverse_of: :container
  has_many :collection_objects, through: :container_items, source: :contained_object, source_type: 'CollectionObject', validate: false
  has_many :collection_profiles

  validates :type, presence: true
  validate :enclosing_container_is_valid
  validate :type_is_valid

  before_destroy :check_for_children

  def type_is_valid
    raise ActiveRecord::SubclassNotFound, 'Invalid subclass' if type && !Container.descendants.map(&:name).include?(type)
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

  # @return [Scope]
  #   CollectionObjects, all of them, for this container
  def all_collection_objects
    CollectionObject.joins(container: [:container_items]).where(container_items: {container_id: self_and_descendants.pluck(:id)})
  end

  # @return [Container]
  #   places all objects in a new, unsaved container and returns that container, unsaved!
  def self.containerize(objects, klass = Container::Virtual)
    c = klass.new
    objects.each do |o|
      c.container_items.build(contained_object: o)
    end
    c
  end

  # @return [Array] of ids of the container contents
  def dump_container_contents
    retval = []
    container_items.each { |item|
      case item.contained_object_type
        when /contain/i # if this item is a container, try to dump the contents
          retval.push(item.contained_object.dump_container_contents)
        else # otherwise, just include whatever it is
          retval.push(item.contained_object)
      end
    }
    retval.flatten
  end

  # @return [Array of {Object}s]
  #   all objects contained in this and nested containers
  def all_objects
    dump_container_contents
    #  all_containers.collect{|c| c.container_item.collect{|ci| ci.contained_object}}.flatten
    #  container_items = ContainerItem.joins(:containers).where(containers: {left:
  end

  def self.find_for_autocomplete(params)
    Queries::ContainerAutocompleteQuery.new(params[:term], project_id: params[:project_id]).result
  end

  protected

  def check_for_children
    unless leaf?
      errors[:base] << "has attached names, delete these first"
      return false
    end
  end

  def enclosing_container_is_valid
    if self.parent
      if !self.class.valid_parents.include?(self.parent.type)
        errors.add(:type, "#{self.class.name} can not be nested in the parent container type #{self.parent.class.name}")
      end
    end
  end

  def process
    loan      = Loan.find(3111)
    site      = loan.loan_items[0].loan_item_object
    building  = site.container_items[0].contained_object
    room      = building.container_items[0].contained_object
    vial_rack = room.container_items[0].contained_object
    vial      = vial_rack.container_items[0].contained_object
    specimens = vial.container_items
  end

end

Dir[Rails.root.to_s + '/app/models/container/**/*.rb'].each { |file| require_dependency file }
