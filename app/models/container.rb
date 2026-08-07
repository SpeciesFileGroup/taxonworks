# A container localizes the proximity of one ore more physical things, at this point in the TW UI this is restricted to a number of collection objects.
#
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

  attr_accessor :empty_container

  include Housekeeping

  # !! Must come before Shared::Containable
  before_destroy :empty_contents, if: -> { empty_container }
  before_destroy :check_for_contents

  include Shared::Containable
  include Shared::Depictions
  include Shared::Identifiers
  include Shared::Labels
  include Shared::Loanable
  include Shared::Tags
  include Shared::IsData
  include SoftValidation

  has_many :collection_profiles, inverse_of: :container, dependent: :restrict_with_error

  validates :type, presence: true
  validate :type_is_valid

  validates :asserted_percent_empty,
    numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 100.0 },
    allow_nil: true

  validates :asserted_percent_earmarked,
    numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 100.0 },
    allow_nil: true

  validate :earmarked_requires_sufficient_empty
  validate :size_does_not_exclude_placed_items, if: :persisted?

  # @return [ContainerItem Scope]
  #    return all ContainerItems contained in this container (non recursive)
  # TODO: fix Please call `reload_container_item` instead. (called from container_items at /Users/jrflood/src/taxonworks/app/models/container.rb:43)
  #
  def container_items
    container_item&.children || ContainerItem.none
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
    container_items.containing_collection_objects.pluck(:id)
  end

  # @return [Array] of CollectionObject#id of this container's contents (recursive)
  def all_collection_object_ids
    # all_container_items.containing_collection_objects.pluck(:id)
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

  def self.dimensions
    {}
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

  # @param params [ActionController::Parameters, Hash] with keys:
  #   building_id [Integer] id of the parent Container::Building
  #   drawer_type [String] full STI type name of the drawer, e.g. 'Container::Drawer::CalAcademy'
  #   rooms [Integer] number of Room containers to create
  #   cabinets [Integer] number of Cabinet containers per Room
  #   drawers [Integer] number of Drawer containers per Cabinet
  #   cabinet_size_x [Integer, nil] default size_x applied to each created cabinet
  #   cabinet_size_y [Integer, nil] default size_y applied to each created cabinet
  #   cabinet_size_z [Integer, nil] default size_z applied to each created cabinet
  #   asserted_percent_empty [Float, nil] default value applied to each created drawer
  #   asserted_percent_earmarked [Float, nil] default value applied to each created drawer
  # @return [Array<Container::Room>] the created Room containers, or false on failure
  def self.scaffold(params)
    building_id   = params[:building_id].to_i
    drawer_type   = params[:drawer_type].to_s.presence || 'Container::Drawer'
    room_count    = params[:rooms].to_i
    cabinet_count = params[:cabinets].to_i
    drawer_count  = params[:drawers].to_i

    cabinet_defaults = {}
    cabinet_defaults[:size_x] = params[:cabinet_size_x].presence&.to_i unless params[:cabinet_size_x].nil?
    cabinet_defaults[:size_y] = params[:cabinet_size_y].presence&.to_i unless params[:cabinet_size_y].nil?
    cabinet_defaults[:size_z] = params[:cabinet_size_z].presence&.to_i unless params[:cabinet_size_z].nil?

    drawer_defaults = {}
    drawer_defaults[:asserted_percent_empty] = params[:asserted_percent_empty].presence&.to_f     unless params[:asserted_percent_empty].nil?
    drawer_defaults[:asserted_percent_earmarked] = params[:asserted_percent_earmarked].presence&.to_f unless params[:asserted_percent_earmarked].nil?

    return false if building_id == 0 || room_count < 1 || cabinet_count < 1 || drawer_count < 1

    # The drawer class must exist; if not, fail early.
    begin
      drawer_klass = drawer_type.constantize
    rescue NameError
      return false
    end

    # Not customizable yet
    cabinet_klass = Container::Cabinet

    created_rooms = []

    begin
      Container.transaction do
        building = Container.find(building_id)

        room_count.times do
          room = Container::Room.create!
          building.add_container_items([room])

          cabinet_count.times do
            cabinet = cabinet_klass.create!(cabinet_defaults)
            room.add_container_items([cabinet])

            drawers = drawer_count.times.map { drawer_klass.create!(drawer_defaults) }
            cabinet.add_container_items(drawers)
          end

          created_rooms << room
        end
      end
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound

      return false
    end



    created_rooms
  end

  # @return [Boolean]
  # add the objects to this container
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

  def empty_contents
    container_items.delete_all
  end

  def type_is_valid
    raise ActiveRecord::SubclassNotFound, 'Invalid subclass' if type && !CONTAINER_TYPES.include?(type)
  end

  # Prevent shrinking a dimension when placed container items would fall
  # outside the new boundary on that axis.
  def size_does_not_exclude_placed_items
    {
      size_x: :disposition_x,
      size_y: :disposition_y,
      size_z: :disposition_z
    }.each do |size_attr, disp_attr|
      next unless send(:"#{size_attr}_changed?")
      new_val = send(size_attr)
      old_val = send(:"#{size_attr}_was")
      next unless new_val.present? && old_val.present? && new_val < old_val
      if container_items.where("#{disp_attr} > ?", new_val).exists?
        errors.add(:base, 'Resize would impact placed containers')
        return
      end
    end
  end

  def earmarked_requires_sufficient_empty
    return if asserted_percent_earmarked.nil?
    if asserted_percent_empty.nil?
      errors.add(:asserted_percent_empty, 'must be present when earmarked is set')
    elsif asserted_percent_empty < asserted_percent_earmarked
      errors.add(:asserted_percent_empty, 'must be greater than or equal to asserted percent earmarked')
    end
  end

  def check_for_contents
    if !is_empty?
      errors.add(:base, 'is not empty, empty it before destroying it')
      throw :abort
    end
  end

end
