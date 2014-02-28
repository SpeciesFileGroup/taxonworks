class Container < ActiveRecord::Base
  acts_as_nested_set scope: [:project_id]

  include Housekeeping
  include Shared::Identifiable
  include Shared::Containable

  belongs_to :otu

  has_many :physical_collection_objects
  has_many :collection_profiles
  has_many :collection_items

  before_validation :check_type

  #CONTAINER_TYPES = %w(dry wet slide)

  # Return a String with the "common" name for this class.
  def self.class_name
    self.type_name.demodulize.underscore.humanize.downcase
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

  protected

  #region Validation

  def check_type
    unless CONTAINER_TYPES.include?(self.type)
      errors.add(:type, 'Not a legal type of container')
    end
  end

  #endregion

end

