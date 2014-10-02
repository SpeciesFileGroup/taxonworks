class Container < ActiveRecord::Base
  acts_as_nested_set scope: [:project_id]

  include Housekeeping
  include Shared::IsData 
  include Shared::Identifiable
  include Shared::Containable
  include Shared::Taggable
  include SoftValidation

  # TODO: rethinking this 
  # belongs_to :otu

  has_many :container_items, inverse_of: :container # , validate: false 
  # has_many :contained_objects, through: :container_items, source: :contained_object, validate: false, source_type: true
  has_many :collection_objects, through: :container_items, source: :contained_object,  source_type: 'CollectionObject', validate: false 
  has_many :collection_profiles

  soft_validate(:sv_parent_type, set: :parent_type)

  before_validation :check_type

  # Return a String with the "common" name for this class.
  def self.class_name
    self.name.demodulize.underscore.humanize.downcase
  end

  def type_name
    r = self.type.to_s
    CONTAINER_TYPE_NAMES.include?(r) ? r : nil
  end

  def type_class=(value)
    write_attribute(:type, value.to_s)
  end

  def type_class
    r = read_attribute(:type).to_s
    r = CONTAINER_TYPE_NAMES.include?(r) ? r.safe_constantize : nil
    r
  end

  def self.valid_parents
    CONTAINER_TYPE_NAMES
  end

  # TODO: 
  def self.containerize(objects)
    c = Container.new
    objects.each do |o|
      c.container_items.build(contained_object: o)
    end
    c
  end

  protected

  #region Validation

  def check_type
    unless CONTAINER_TYPE_NAMES.include?(self.type.to_s)
      errors.add(:type, 'Not a legal type of container')
    end
  end

  #endregion

  #region SoftValidation

  def sv_parent_type
    unless self.parent_id.nil?
      unless self.type_class.valid_parents.include?(self.parent.type.to_s)
        soft_validations.add(:type, "This container has inappropriate parent container: '#{self.parent.type_class.class_name}'")
      end
    end
  end

  #endregion

end

