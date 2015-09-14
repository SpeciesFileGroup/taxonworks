# A container localizes the proximity of one ore more physical things, at this point in TW this is restricted to a number of collection objects.
#
# @!attribute lft
#   @return [Integer]
#   @todo
#
# @!attribute rgt
#   @return [Integer]
#   @todo
#
# @!attribute parent_id
#   @return [Integer]
#   @todo
#
# @!attribute depth
#   @return [Integer]
#   @todo
#
# @!attribute type
#   @return [String]
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute otu_id
#   @return [Integer]
#   @todo
#
# @!attribute name
#   @return [String]
#   @todo
#
# @!attribute disposition
#   @return [String]
#   @todo
#
class Container < ActiveRecord::Base
  acts_as_nested_set scope: [:project_id]

  include Housekeeping
  include Shared::Containable
  include Shared::Identifiable
  include Shared::Taggable
  include Shared::IsData
  include SoftValidation

  has_many :container_items, inverse_of: :container 
  has_many :collection_objects, through: :container_items, source: :contained_object,  source_type: 'CollectionObject', validate: false 
  has_many :collection_profiles

  validates :type, presence: true
  validate :enclosing_container_is_valid

  # @return [String]
  #   the "common name" of this class
  def self.class_name
    self.name.demodulize.underscore.humanize.downcase
  end

  # @return [Array of Strings]
  #   valid containers class names that this container can fit in, by default none
  def self.valid_parents
    [ ]
  end

  # @return [Container]
  #   places all objects in a new, unsaved container and returns that container, unsaved!
  def self.containerize(objects, klass = Container::Virtual )
    c = klass.new 
    objects.each do |o|
      c.container_items.build(contained_object: o)
    end
    c
  end

  protected

  def enclosing_container_is_valid
    if self.parent 
      if !self.class.valid_parents.include?(self.parent.type)
        errors.add(:type, "#{self.class.name} can not be nested in the parent container type #{self.parent.class.name}" )
      end
    end
  end

end

